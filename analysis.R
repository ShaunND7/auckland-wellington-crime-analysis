# DATA401 | Recorded assault and theft timing, 2023–2025
# Source: data/police_raw.csv. Outputs are used by report.qmd.

# 1. Packages
library(tidyverse)
library(janitor)

# 2. Import and standardise column names
police_raw <- read_csv(
  "data/police_raw.csv",
  show_col_types = FALSE
) %>%
  clean_names()

required_columns <- c(
  "year_month", "territorial_authority", "anzsoc_division",
  "victimisations", "occurrence_day_of_week", "occurrence_hour_of_day",
  "anzsoc_group"
)
stopifnot(all(required_columns %in% names(police_raw)))


# 3. Define study population (two cities, two offence divisions, three years)
crime_study <- police_raw %>%
  mutate(
    year = as.integer(str_extract(year_month, "\\d{4}$")),
    city = str_remove(territorial_authority, "\\.$")
  ) %>%
  filter(
    city %in% c("Auckland", "Wellington City"),
    anzsoc_division %in% c("Assault", "Theft"),
    year %in% 2023:2025
  ) %>%
  select(
    city,
    year,
    year_month,
    offence = anzsoc_division,
    offence_group = anzsoc_group,
    victimisations,
    day = occurrence_day_of_week,
    hour = occurrence_hour_of_day
  )


# 4. Flag usable occurrence times; retain incomplete records for coverage checks
valid_days <- c(
  "Monday", "Tuesday", "Wednesday", "Thursday",
  "Friday", "Saturday", "Sunday"
)

crime_study <- crime_study %>%
  mutate(
    day_known = day %in% valid_days,
    hour_known = hour %in% 0:23
  )

# 5. Data coverage: sum victimisations, not source rows
timing_check <- crime_study %>%
  group_by(city, offence) %>%
  summarise(
    total = sum(victimisations),
    unknown_day = sum(victimisations[!day_known]),
    unknown_hour = sum(victimisations[!hour_known]),
    both_known = sum(victimisations[day_known & hour_known]),
    .groups = "drop"
  ) %>%
  mutate(
    unknown_day_pct = round(100 * unknown_day / total, 1),
    unknown_hour_pct = round(100 * unknown_hour / total, 1),
    both_known_pct = round(100 * both_known / total, 1)
  )

# 6. Day-of-week proportions (denominator: known-day victimisations)
day_summary <- crime_study %>%
  filter(day_known) %>%
  mutate(
    day = factor(day, levels = valid_days)
  ) %>%
  group_by(city, offence, day) %>%
  summarise(
    victimisations = sum(victimisations),
    .groups = "drop"
  ) %>%
  group_by(city, offence) %>%
  mutate(
    proportion = victimisations / sum(victimisations)
  ) %>%
  ungroup()

# Compare day-of-week patterns
day_plot <- ggplot(
  day_summary,
  aes(x = day, y = proportion, fill = offence)
) +
  geom_col(position = "dodge", width = 0.75) +
  facet_wrap(~ city, ncol = 1) +
  scale_y_continuous(
    labels = scales::label_percent(accuracy = 1),
    expand = expansion(mult = c(0, 0.08))
  ) +
  scale_x_discrete(
    labels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
  ) +
  scale_fill_manual(
    values = c("Assault" = "#C44E52", "Theft" = "#4C9FAD")
  ) +
  labs(
    title = "Recorded assault and theft by day of week",
    subtitle = "Auckland and Wellington City, 2023–2025",
    x = NULL,
    y = "Share of victimisations with a known day",
    fill = "Offence",
    caption = paste(
      "Source: NZ Police, Victimisation Time and Place.",
      "Unknown days excluded; percentages calculated within each city and offence.",
      sep = "\n"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(hjust = 0)
  )

# Calculate weekend shares among victimisations with a known day
weekend_summary <- day_summary %>%
  group_by(city, offence) %>%
  summarise(
    known_day_total = sum(victimisations),
    weekend_total = sum(
      victimisations[day %in% c("Saturday", "Sunday")]
    ),
    .groups = "drop"
  ) %>%
  mutate(
    weekend_pct = round(
      100 * weekend_total / known_day_total, 1
    )
  )

# 7. Hourly proportions (denominator: known-hour victimisations)
hour_summary <- crime_study %>%
  filter(hour_known) %>%
  group_by(city, offence, hour) %>%
  summarise(
    victimisations = sum(victimisations),
    .groups = "drop"
  ) %>%
  group_by(city, offence) %>%
  mutate(
    proportion = victimisations / sum(victimisations) 
  ) %>%
  ungroup()

# Compare hourly patterns
hour_plot <- ggplot(
  hour_summary,
  aes(x = hour, y = proportion, colour = offence)
) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 1.5) +
  facet_wrap(~ city, ncol = 1) +
  scale_x_continuous(
    breaks = c(0, 3, 6, 9, 12, 15, 18, 21, 23),
    labels = c(
      "00", "03", "06", "09", "12",
      "15", "18", "21", "23"
    )
  ) +
  scale_y_continuous(
    labels = scales::label_percent(accuracy = 1),
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.08))
  ) +
  scale_colour_manual(
    values = c("Assault" = "#C44E52", "Theft" = "#4C9FAD")
  ) +
  labs(
    title = "Recorded assault and theft by time of day",
    subtitle = "Auckland and Wellington City, 2023–2025",
    x = "Occurrence hour (24-hour clock)",
    y = "Share of victimisations with a known hour",
    colour = "Offence",
    caption = paste(
      "Source: NZ Police, Victimisation Time and Place.",
      "Unknown hours excluded; percentages calculated within each city and offence.",
      sep = "\n"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    panel.grid.minor = element_blank(),
    plot.caption = element_text(hjust = 0)
  )

# 8. Joint day-hour proportions (denominator: complete-timing victimisations)
day_hour_summary <- crime_study %>%
  filter(day_known, hour_known) %>%
  group_by(city, offence, day, hour) %>%
  summarise(
    victimisations = sum(victimisations),
    .groups = "drop"
  ) %>%
  group_by(city, offence) %>%
  complete(
    day = valid_days,
    hour = 0:23,
    fill = list(victimisations = 0)
  ) %>%
  mutate(
    day = factor(day, levels = valid_days),
    proportion = victimisations / sum(victimisations)
  ) %>%
  ungroup()

# Show the combined day-and-hour patterns
timing_heatmap <- ggplot(
  day_hour_summary,
  aes(x = hour, y = day, fill = proportion)
) +
  geom_tile() +
  facet_grid(city ~ offence) +
  scale_x_continuous(
    breaks = c(0, 6, 12, 18, 23),
    labels = c("00", "06", "12", "18", "23"),
    expand = c(0, 0)
  ) +
  scale_y_discrete(
    limits = rev(valid_days),
    labels = c(
      Monday = "Mon", Tuesday = "Tue",
      Wednesday = "Wed", Thursday = "Thu",
      Friday = "Fri", Saturday = "Sat", Sunday = "Sun"
    ),
    expand = c(0, 0)
  ) +
  scale_fill_viridis_c(
    option = "C",
    labels = scales::label_percent(accuracy = 0.1)
  ) +
  labs(
    title = "When recorded assault and theft occurred",
    subtitle = "Auckland and Wellington City, 2023–2025",
    x = "Occurrence hour (24-hour clock)",
    y = NULL,
    fill = "Share of\nvictimisations",
    caption = paste(
      "Source: NZ Police, Victimisation Time and Place.",
      "Only known days and hours included; percentages are within each city and offence.",
      sep = "\n"
    )
  ) +
  theme_minimal(base_size = 12) +
  theme(
    panel.grid = element_blank(),
    strip.text = element_text(face = "bold"),
    plot.caption = element_text(hjust = 0)
  )

# Shared definition, used by both overall and annual summaries.
is_weekend_night <- function(day, hour) {
  (day %in% c("Friday", "Saturday") & hour >= 22) |
    (day %in% c("Saturday", "Sunday") & hour < 6)
}

# 9. Weekend nights: Friday/Saturday 22:00–05:59 next day
weekend_night_summary <- day_hour_summary %>%
  mutate(
    weekend_night = is_weekend_night(day, hour)
  ) %>%
  group_by(city, offence) %>%
  summarise(
    both_known_total = sum(victimisations),
    weekend_night_total = sum(
      victimisations[weekend_night]
    ),
    .groups = "drop"
  ) %>%
  mutate(
    weekend_night_pct = round(
      100 * weekend_night_total / both_known_total, 1
    )
  )

# 10. Annual check of weekend-night proportions
yearly_night_summary <- crime_study %>%
  filter(day_known, hour_known) %>%
  mutate(
    weekend_night = is_weekend_night(day, hour)
  ) %>%
  group_by(city, offence, year) %>%
  summarise(
    both_known_total = sum(victimisations),
    weekend_night_total = sum(
      victimisations[weekend_night]
    ),
    .groups = "drop"
  ) %>%
  mutate(
    weekend_night_pct = round(
      100 * weekend_night_total / both_known_total, 1
    )
  )

# 11. Extreme bounds for missing timing (not confidence intervals)
missing_time_bounds <- weekend_night_summary %>%
  left_join(
    timing_check %>% select(city, offence, total),
    by = c("city", "offence")
  ) %>%
  mutate(
    incomplete_timing = total - both_known_total,
    lower_pct = round(
      100 * weekend_night_total / total, 1
    ),
    upper_pct = round(
      100 * (weekend_night_total + incomplete_timing) / total, 1
    )
  ) %>%
  select(
    city,
    offence,
    weekend_night_pct,
    incomplete_timing,
    lower_pct,
    upper_pct
  )

# 12. Summary used in the Quarto report
report_summary <- timing_check %>%
  select(
    city, offence, total,
    unknown_day_pct, unknown_hour_pct
  ) %>%
  left_join(
    weekend_summary %>%
      select(city, offence, weekend_pct),
    by = c("city", "offence")
  ) %>%
  left_join(
    weekend_night_summary %>%
      select(city, offence, weekend_night_pct),
    by = c("city", "offence")
  )

