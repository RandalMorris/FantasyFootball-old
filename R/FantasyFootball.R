#' @import tidyverse httr janitor rvest glue
#' @importFrom lubridate year
.onLoad <- function(libname, pkgname){
  player_table <<- httr::GET("https://www70.myfantasyleague.com/2019/export?TYPE=players&DETAILS=1&SINCE=&PLAYERS=&JSON=1") %>%
    httr::content() %>% `[[`("players") %>% `[[`("player") %>%
    purrr::map(tibble::as.tibble) %>%
    dplyr::bind_rows() %>%
    dplyr::filter(position %in% c("QB", "RB", "WR", "TE", "PK", "Def", "DE", "DT", "LB", "CB", "S")) %>%
    dplyr::select(id, name, position, team, weight, draft_year, draft_team, draft_round, draft_pick, birthdate) %>%
    tidyr::extract(name, c("last_name", "first_name"), "(.+),\\s(.+)") %>%
    dplyr::mutate(birthdate = as.Date(as.POSIXct(as.numeric(birthdate), origin = "1970-01-01")),
                  position = dplyr::recode(position, Def = "DST", PK = "K"),
                  age = as.integer(lubridate::year(Sys.time()) - lubridate::year(birthdate)),
                  exp = 2019 - as.integer(draft_year))
  
    salary_url <- paste("https://www.fantasypros.com/daily-fantasy/nfl/draftkings-salary-changes.php")

    salary_table <-  salary_url %>%  textreadr::read_html() %>% rvest::html_node("table") %>%
      rvest::html_table() %>%
      dplyr::select(Player, Salary = "This Week") %>%
      tidyr::extract(Player, c("Player", "Team", "Pos"),
      "(.+)\\s\\(([A-Z]+)\\s\\-\\s([A-Z]+)\\)$") %>%
      dplyr::mutate(Salary = as.numeric(gsub("[\\$,]","", Salary)))
    names(salary_table)[1:4] <- c("name","team","position","salary")

    player_dfs <- player_table
    player_dfs$first_name <- paste(player_dfs$first_name, player_dfs$last_name)
    names(player_dfs)[3:5] <- c("name","team","position")
    player_dfs = subset(player_dfs, select = c(id,name,team,position))

    salary_table <- dplyr::select(player_dfs, id,name,team,position) %>%
      inner_join(salary_table, by = c("name"))
    names(salary_table)[3:4] <- c("team","position")
    salary_table = subset(salary_table, select = -c(team.y, position.y))       

    dfs_data <- dplyr::select(projections, id,name,team,position, avg_type, points, pos_rank, floor, ceiling, tier, risk) %>%
      inner_join(salary_table, by = c("id"))
    names(dfs_data)[2:4] <- c("name","team","position")
    dfs_data = subset(dfs_data, select = -c(name.y,team.y, position.y))     
    rm(salary_table,player_dfs)
}
