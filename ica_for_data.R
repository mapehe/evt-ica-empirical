####
#
# Cashflow data subjected to ICA
#
####

# The file reads the cashflow-data 54datasets3.csv from /data and outputs the following files there
# 1. sobi_holidays_0.csv
# 2. sobi_holidays_1.csv
#
# where the first contains the "independent components" extracted from the first 10 companies time series when
# the holidays have been removed from the data and the second one the same with the holidays



# Needed packages
library("tidyverse")
library("lubridate")
library("JADE")
library("forcats")

# Set the data folder

if(file.exists("DATA_DIR.txt")){
    my_data_path <- readChar("DATA_DIR.txt", file.info("DATA_DIR.txt")$size)
} else{
    my_data_path <- "\\\\home.org.aalto.fi\\virtaj9\\data\\Documents\\evt-ica-empirical\\"
}

# Transpose to wide form, companies as columns
cf <- read.csv(paste0(my_data_path, "54datasets3.csv")) %>%
  mutate(Company = factor(Company, labels = paste("Company_", 1:54, sep = ""))) %>%
  spread(Company, NetCF) %>%
  mutate(Holiday = factor(Holiday, labels = c("No", "Yes"))) %>%
  mutate(Date = as.Date(Date))

# Select only the first 10 companies as they have observations for the same set of 545 dates
# (there are no dates for which observations for all companies exist)
cf_10 <- cf %>%
  filter(!is.na(rowSums(.[5:14]))) %>%
  select(-(Company_11:Company_54))


##### ICA with the holiday dates in the data

# Run SOBI (a blinbd source separation method, something like ICA for time series)
sobi_10 <- SOBI(as.matrix(cf_10[, 5:14]))

# Parse results into a wide data frame
res_10_wide <- data.frame(Date = cf_10$Date,
                     Holiday = cf_10$Holiday,
                     DayWeek = cf_10$DayWeek,
                     DayMonth = cf_10$DayMonth,
                     sobi_10$S)

# Parse results into a long data frame
res_10_long <- res_10_wide %>%
          gather(Component, Value, -Date, -Holiday, -DayWeek, -DayMonth) %>%
          mutate(Component = fct_relevel(as.factor(Component), "Series.10", after = 9))

# Collect the holiday dates
holidays <- cf_10 %>%
  filter(Holiday == "Yes") %>%
  select(Date)

# Plot of the resulting estimated 10 time series with holidays marked as red
ggplot(res_10_long, aes(x = Date, y = Value)) +
  geom_line() +
  facet_wrap(~ Component, ncol = 2) +
  theme_bw() +
  geom_vline(data = holidays, aes(xintercept = Date), col = "red", alpha = 0.2)



##### ICA without the holiday dates in the data

no_holidays <- cf_10 %>%
  filter(Holiday == "No")

sobi_10_no <- SOBI(as.matrix(no_holidays[, 5:14]))


# Parse results into a wide data frame
res_10_wide_no <- data.frame(Date = no_holidays$Date,
                            Holiday = no_holidays$Holiday,
                            DayWeek = no_holidays$DayWeek,
                            DayMonth = no_holidays$DayMonth,
                            sobi_10_no$S)

# Parse results into a long data frame
res_10_long_no <- res_10_wide_no %>%
  gather(Component, Value, -Date, -Holiday, -DayWeek, -DayMonth) %>%
  mutate(Component = fct_relevel(as.factor(Component), "Series.10", after = 9))


# Plot of the resulting estimated 10 time series
ggplot(res_10_long_no, aes(x = Date, y = Value)) +
  geom_line() +
  facet_wrap(~ Component, ncol = 2) +
  theme_bw()




##### Save both datasets into .csv

write.csv(res_10_wide_no, paste0(my_data_path, "sobi_holidays_0.csv"))
write.csv(res_10_wide, paste0(my_data_path, "sobi_holidays_1.csv"))
