
# Loading in necessary libraries

library(tidyverse)

# Loading in raw data

polls_past_state <- read_csv("data/08-prediction/raw-data/pollavg_bystate_1968-2016.csv")
polls_2020 <- read_csv("data/08-prediction/raw-data/president_polls.csv")
past_elections <- read_csv("data/08-prediction/raw-data/popvote_1948-2016.csv")
past_elections_state <- read_csv("data/08-prediction/raw-data/popvote_bystate_1948-2016.csv")

# Cleaning for Past State Polls:
# 1) Using only polls 22 weeks or closer to the election
# 2) Removing split states
# 3) Averaging for all candidates per year (by party and state)
# 4) Removing years where there were not many state polls

polls_past_state_clean <- polls_past_state %>% 
  filter(weeks_left <= 22,
         !state %in% c("ME-1", "ME-2", "NE-1", "NE-2", "NE-3")) %>% 
  group_by(year, state, party) %>% 
  summarize(average_poll = mean(avg_poll), .groups = "drop") %>% 
  filter(year >= 1988)

# write_csv(polls_past_state_clean, "data/08-prediction/pollavg_bystate_1968-2016_clean.csv")

# Cleaning for 2020 Polls:
# 1) Removing national polls and split states
# 2) Cleaning up dates
# 3) Using only polls 22 weeks or closer to the election (After June)
# 4) Averaging for all candidates (by party and state)
# 5) Selecting the democrat and republican parties and renaming them

polls_2020_state_clean <- polls_2020 %>% 
  filter(!is.na(state),
         !state %in% c("Maine CD-1", "Maine CD-2", "Nebraska CD-1", "Nebraska CD-2")) %>% 
  mutate(start_date = as.Date(end_date, "%m/%d/%y")) %>% 
  filter(start_date >= "2020-06-01") %>% 
  group_by(candidate_party, state) %>% 
  summarize(average_poll = mean(pct), .groups = "drop") %>% 
  filter(candidate_party %in% c("DEM", "REP")) %>% 
  mutate(candidate_party = case_when(
    candidate_party == "DEM" ~ "democrat",
    candidate_party == "REP" ~ "republican"
  )) %>% 
  rename(party = candidate_party)

# write_csv(polls_2020_state_clean, "data/08-prediction/president_polls_state_clean.csv")

# Cleaning for past elections:
# 1) Pivoting D and R and fixing party names
# 2) Joining in national data to get needed predictors
# 3) Filtering for year >= 1988 b/c of limited state polls before then

past_elections_state_clean <- past_elections_state %>% 
  select(-c(total, D_pv2p, R_pv2p)) %>% 
  pivot_longer(D:R, names_to = "party", values_to = "votes") %>% 
  mutate(party = case_when(
    party == "D" ~ "democrat",
    party == "R" ~ "republican"
  )) %>% 
  left_join(past_elections %>% 
              select(year, party, winner, incumbent, incumbent_party), by = c("year", "party")) %>% 
  filter(year >= 1988)

# write_csv(past_elections_state_clean, "data/08-prediction/popvote_bystate_1948-2016_clean.csv")  

# Presidential Job Approval Data Cleaning is located in the national_model_data_cleaning.R file
