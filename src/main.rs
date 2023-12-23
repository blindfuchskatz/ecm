use futures::{executor::block_on, stream::StreamExt};
use paho_mqtt as mqtt;
use std::{env, process, time::Duration};

mod file_writer;

const QOS: &[i32] = &[1, 1];
use text_colorizer::*;

fn print_usage() {
    eprintln!("Usage: ecm <meter data path> <url mqtt broker> <topic_1> <topic_2> <topic_n>")
}

#[derive(Debug)]
struct Arguments {
    meter_data_file: String,
    host: String,
    topics: Vec<String>,
}

fn pars_args() -> Arguments {
    let args: Vec<String> = env::args().skip(1).collect();
    if args.len() < 3 {
        print_usage();
        eprintln!(
            "{} wrong number of arguments: expect at least 3, got {}.",
            "Error:".red().bold(),
            args.len()
        );
        std::process::exit(1);
    }

    Arguments {
        meter_data_file: args[0].clone(),
        host: args[1].clone(),
        topics: args[2..].to_vec(),
    }
}

fn main() {
    // Initialize the logger from the environment
    env_logger::init();

    let args = pars_args();
    println!("Connecting to the MQTT server at '{}'...", args.host);
    println!("Subscribe to topics '{:?}'...", args.topics);

    // Create the client. Use a Client ID for a persistent session.
    // A real system should try harder to use a unique ID.
    let create_opts = mqtt::CreateOptionsBuilder::new_v3()
        .server_uri(args.host)
        .client_id("rust_async_subscribe")
        .finalize();

    // Create the client connection
    let mut cli = mqtt::AsyncClient::new(create_opts).unwrap_or_else(|e| {
        println!("Error creating the client: {:?}", e);
        process::exit(1);
    });

    if let Err(err) = block_on(async {
        // Get message stream before connecting.
        let mut strm = cli.get_stream(25);

        // Define the set of options for the connection
        let lwt = mqtt::Message::new(
            "test/lwt",
            "[LWT] Async subscriber lost connection",
            mqtt::QOS_1,
        );

        // Create the connect options, explicitly requesting MQTT v3.x
        let conn_opts = mqtt::ConnectOptionsBuilder::new_v3()
            .keep_alive_interval(Duration::from_secs(30))
            .clean_session(false)
            .will_message(lwt)
            .finalize();

        // Make the connection to the broker
        cli.connect(conn_opts).await?;

        println!("Subscribing to topics: {:?}", args.topics);
        cli.subscribe_many(&args.topics, QOS).await?;

        // Just loop on incoming messages.
        println!("Waiting for messages...");

        let mut rconn_attempt: usize = 0;

        // Note that we're not providing a way to cleanly shut down and
        // disconnect. Therefore, when you kill this app (with a ^C or
        // whatever) the server will get an unexpected drop and then
        // should emit the LWT message.

        let file_writer = file_writer::FileWriter::new(&args.meter_data_file);

        while let Some(msg_opt) = strm.next().await {
            if let Some(msg) = msg_opt {
                println!("{}", msg);
                let meter_data_line = msg.to_string() + &"\n".to_string();
                if let Err(err) = file_writer.append_string(&meter_data_line) {
                    eprintln!("Error: {}", err);
                    process::exit(1);
                }
            } else {
                // A "None" means we were disconnected. Try to reconnect...
                println!("Lost connection. Attempting reconnect...");
                while let Err(err) = cli.reconnect().await {
                    rconn_attempt += 1;
                    println!("Error reconnecting #{}: {}", rconn_attempt, err);
                    // For tokio use: tokio::time::delay_for()
                    async_std::task::sleep(Duration::from_secs(1)).await;
                }
                println!("Reconnected.");
            }
        }

        // Explicit return type for the async block
        Ok::<(), mqtt::Error>(())
    }) {
        eprintln!("{}", err);
    }
}
