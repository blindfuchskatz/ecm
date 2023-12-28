use std::fs::OpenOptions;
use std::io::{self, Write};
use std::path::Path;

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

    pub fn parent_path_exist(&self, file_path: &str) -> bool {
        // Create a Path object from the file path
        let path = Path::new(file_path);

        // Extract the directory part of the path
        let directory_path = path.parent();

        // Check if the directory path exists
        if let Some(directory) = directory_path {
            if directory.exists() {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    }
}
