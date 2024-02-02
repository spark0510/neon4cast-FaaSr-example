forecast_model_prepare_sites <- function(folder){
    library(tidyverse)

    forecast_date <- Sys.Date()
    noaa_date <- Sys.Date() - days(3)  #Need to use yesterday's NOAA forecast because today's is not available yet

    # Step 0: Define a unique name which will identify your model in the leaderboard and connect it to team members info, etc
    #model_id <- "neon4cast_example"

    # Step 1: Download latest target data and site description data
    target <- readr::read_csv(paste0("https://data.ecoforecast.org/neon4cast-targets/",
                                 "aquatics/aquatics-targets.csv.gz"), guess_max = 1e6)
    site_data <- readr::read_csv(paste0("https://raw.githubusercontent.com/eco4cast/neon4cast-targets/",
                                    "main/NEON_Field_Site_Metadata_20220412.csv")) |> 
    dplyr::filter(aquatics == 1)

    # Step 2: Get meterological predictions as drivers
    df_past <- neon4cast::noaa_stage3()

    # FaaSr: make a temporary file
    data <- list(target=target, site_data=site_data, df_past=df_past)
    write_rds(data, "faasr_neon4cast_data.rds")
    FaaSr::faasr_put_file(local_file="faasr_neon4cast_data.rds", remote_folder=folder, remote_file="faasr_neon4cast_data.rds")
}
