# When Do Assault and Theft Victimisations Occur?

### Auckland and Wellington City, New Zealand | 2023–2025

An exploratory data analysis of **recorded assault and theft victimisations** using New Zealand Police *Victimisation Time and Place* data. This project compares how recorded victimisations are distributed across days of the week and hours of the day in Auckland and Wellington City.

Developed for **DATA401 — Introduction to Data Science**, University of Canterbury.

## Research question

**How do the day-of-week and hourly patterns of recorded assault and theft victimisations differ between Auckland and Wellington City during 2023–2025?**

## What the project examines

- Data completeness for recorded occurrence day and hour.
- Day-of-week distributions for assault and theft.
- Hourly distributions using a 24-hour clock.
- Combined day-by-hour patterns using heatmaps.
- The proportion of victimisations recorded during weekend nights, defined as **Friday and Saturday, 22:00–05:59 the following morning**.
- Annual consistency and sensitivity to missing occurrence times.

The analysis uses **descriptive statistics**, not causal inference or predictive modelling. Percentages are calculated within each city and offence category, using the relevant records with known timing information.

## Tools

- **R** and **RStudio**
- **Quarto** for the PDF report
- **tidyverse** for data preparation and visualisation
- **janitor** for column-name cleaning
- **ggplot2** for bar charts, line charts and heatmaps
- **scales** for percentage axis labels

## Project structure

```text
R-Project/
├── R-Project.Rproj       # RStudio project configuration
├── analysis.R            # Data preparation, summaries and plots
├── report.qmd            # Quarto report source
├── report.pdf            # Rendered written report
├── README.md             # Project documentation
├── AI_DECLARATION.txt    # AI assistance disclosure
└── data/
    └── police_raw.csv    # Source data (see Data section)
```

## Reproducing the analysis

1. Install **R**, **RStudio** (optional) and **Quarto**. A working LaTeX installation, such as TinyTeX, is needed to render the PDF.
2. Open `R-Project.Rproj`, or set your working directory to the project root.
3. Install the required R packages:

   ```r
   install.packages(c("tidyverse", "janitor", "scales"))
   ```

4. Place the source dataset at `data/police_raw.csv` if it is not already included.
5. Run the analysis:

   ```r
   source("analysis.R")
   ```

6. Render the written report from the project root:

   ```bash
   quarto render report.qmd --to pdf
   ```

The report sources `analysis.R`, so the data and script must be available at their relative paths when rendering.

## Data source and interpretation

**Source:** New Zealand Police, *Police Data NZ — Victimisation Time and Place*.

Data portal: https://www.police.govt.nz/about-us/publications-statistics/data-and-statistics/policedatanz

The analysis covers **2023–2025** and focuses on the **Auckland** and **Wellington City** territorial authorities and the **Assault** and **Theft** offence divisions.

**Important limitations:** These are recorded victimisations in the published dataset, not a measure of all crime or underlying crime risk. The dataset has coverage restrictions, and some records have unknown occurrence days or hours. Differences in recorded counts and distributions should not be interpreted as causal effects. Consult the Police dataset documentation before reusing or redistributing the source data.

> **GitHub note:** If `data/police_raw.csv` is omitted from the public repository because of file size or redistribution considerations, obtain the corresponding dataset from the source and save it under that filename. The report cannot be fully reproduced without the input data.

## AI assistance disclosure

**Tool:** OpenAI ChatGPT (GPT-6).

AI assistance was used for troubleshooting R code and errors; suggestions for cleaning and transforming data; code formatting, indentation and comments; support with bar charts, line charts and heatmaps (including sizing, colours and axes); development of automated reproducibility checks; and grammar and punctuation review. The author reviewed the code, checked analytical outputs and remains responsible for the final analysis and interpretation. See `AI_DECLARATION.txt` if included.

## Author

**Shaun D'Souza**  
Master of Applied Data Science — University of Canterbury

## Project status

Completed as a university coursework project in October 2026.
