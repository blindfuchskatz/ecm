use std::fs::OpenOptions;
use std::io::{self, Write};

pub struct FileWriter {
    file_path: String,
}

impl FileWriter {
    // Constructor to create a new instance of FileWriter
    pub fn new(file_path: &str) -> Self {
        FileWriter {
            file_path: file_path.to_string(),
        }
    }

    // Method to append a string to the file
    pub fn append_string(&self, content: &str) -> io::Result<()> {
        // Open the file with append mode
        let mut file = OpenOptions::new()
            .create(true)
            .append(true)
            .open(&self.file_path)?;

        // Write the content to the file
        file.write_all(content.as_bytes())?;

        Ok(())
    }
}
