get_target_data <- function(folder, output_target, output_blinded) {
  # Download target data
  target <- readr::read_csv("https://data.ecoforecast.org/neon4cast-targets/aquatics/aquatics-targets.csv.gz")

  # Process data
  aquatic <- target %>%
    tidyr::pivot_wider(names_from = "variable", values_from = "observation") %>%
    tsibble::as_tsibble(index = datetime, key = site_id)

  # Save the full dataset
  readr::write_csv(aquatic %>% tsibble::as_tibble(), "aquatic_full.csv")

  # Create blinded dataset (drop last 35 days)
  blinded_aquatic <- aquatic %>%
    dplyr::filter(datetime < max(datetime) - 35) %>%
    tsibble::fill_gaps()

  # Save the blinded dataset
  readr::write_csv(blinded_aquatic %>% as_tibble(), "blinded_aquatic.csv")

  # Upload both files to S3
  FaaSr::faasr_put_file(local_file = "aquatic_full.csv", remote_folder = folder, remote_file = output_target)
  FaaSr::faasr_put_file(local_file = "blinded_aquatic.csv", remote_folder = folder, remote_file = output_blinded)

  # Log message
  log_msg <- paste0("Function get_target_data finished; outputs written to folder ", folder, " in default S3 bucket")
  FaaSr::faasr_log(log_msg)
}
