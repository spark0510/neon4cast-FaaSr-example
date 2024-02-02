forecast_model_prepare_sites <- function(folder){
    library(tidyverse)
    library(neon4cast)

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

    # FaaSr: compare data - stop if there's no change in data
    data <- list(target=target, site_data=site_data, df_past=df_past)
    try(FaaSr::faasr_get_file(local_file="faasr_neon4cast_data.rds", remote_folder=folder, remote_file="faasr_neon4cast_data.rds"), silent=TRUE)
    data_pre <- try(read_rds("faasr_neon4cast_data.rds"), silent=TRUE)
    if (identical(data, data_pre)){
        faasr_log("no data changed")
        stop()
    }

    # FaaSr: make a temporary file
    write_rds(data, "faasr_neon4cast_data.rds")
    FaaSr::faasr_put_file(local_file="faasr_neon4cast_data.rds", remote_folder=folder, remote_file="faasr_neon4cast_data.rds")
}
