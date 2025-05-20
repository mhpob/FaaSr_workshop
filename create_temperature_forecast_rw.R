create_temperature_forecast_rw <- function(folder, input_file, output_file) {
  # Create temperature forecast using random walk model

  # Load required libraries
  library(neon4cast)
  library(tidyverse)
  library(fable)
  library(tsibble)

  # Download the blinded dataset
  FaaSr::faasr_get_file(remote_folder = folder, remote_file = input_file, local_file = "blinded_aquatic.csv")

  # Read the dataset and convert to tsibble
  blinded_aquatic <- readr::read_csv("blinded_aquatic.csv") %>%
    tsibble::as_tsibble(index = datetime, key = site_id)

  # Create temperature forecast
  temperature_fc_rw <- blinded_aquatic %>%
    fabletools::model(benchmark_rw = fable::RW(temperature)) %>%
    fabletools::forecast(h = "35 days") %>%
    neon4cast::efi_format_ensemble()

  # Save the forecast
  readr::write_csv(temperature_fc_rw, "temperature_fc_rw.csv")

  # Upload the forecast to S3
  FaaSr::faasr_put_file(local_file = "temperature_fc_rw.csv", remote_folder = folder, remote_file = output_file)

  # Log message
  log_msg <- paste0("Function create_temperature_forecast_rw finished; output written to ", folder, "/", output_file, " in default S3 bucket")
  FaaSr::faasr_log(log_msg)
}
