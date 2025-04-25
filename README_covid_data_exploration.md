
# 🦠 COVID-19 Data Exploration Project (SQL)

This project explores global COVID-19 data using **SQL**. It provides insights on infection trends, death rates, population impact, and vaccination progress using real-world datasets. The project is built using **Microsoft SQL Server** with cleaned data from the [Our World in Data](https://ourworldindata.org/coronavirus-source-data) COVID dataset.

---

## 📁 Dataset Source

- [Our World in Data](https://github.com/owid/covid-19-data)
- Tables used:
  - `CovidDeaths$`
  - `CovidVaccinations$`

---

## 🛠️ Tools & Technologies

- SQL Server Management Studio (SSMS)
- Microsoft SQL Server
- Window Functions
- CTEs (Common Table Expressions)
- Temp Tables
- Views
- Aggregate Functions (SUM, MAX, etc.)

---

## 📊 Project Objectives

- Analyze total cases and total deaths globally and by country.
- Calculate death percentage per case.
- Compare COVID-19 infection rates to population.
- Track new and total vaccinations.
- Create a running total of people vaccinated.
- Identify countries with the highest death/infection rates.
- Use SQL views for future visualization tools (e.g., Power BI or Tableau).

---

## 🧠 Key Insights

- Countries with the highest percentage of population infected.
- Countries with the highest COVID death rates.
- Global and continental case and death trends.
- Vaccination progress over time.
- Percentage of population vaccinated using rolling total logic.

---

## 📌 Highlight SQL Concepts

- **Joins** – Combine deaths and vaccination datasets by date/location.
- **Window Functions** – Rolling totals for vaccination data.
- **CTEs** – Improve readability and structure of reusable logic.
- **Temp Tables** – Store intermediate results and perform calculations.
- **Views** – Created for easier data visualization and analysis.

---

## 📁 Files in the Repo

- `covid_data_exploration.sql` — Full SQL script with optimized queries and insights.
- `README.md` — Project overview and description.

---

## 🚀 Getting Started

To run this project:

1. Import the two datasets (`CovidDeaths$` and `CovidVaccinations$`) into SQL Server.
2. Open the `covid_data_exploration.sql` file in SSMS.
3. Execute the script section-by-section to view results and insights.

---

## 📈 Future Scope

- Connect SQL view to **Power BI/Tableau** for interactive visualizations.
- Automate data updates and refreshes.
- Add country-level drilldowns and time-series dashboards.

---

## 💬 Contributions

Feel free to fork the repository and open pull requests. Suggestions and improvements are always welcome!

---

## 📜 License

This project is open-source and available under the [MIT License](LICENSE).

---

## 🙌 Acknowledgments

- [Our World in Data](https://ourworldindata.org/)
- SQL Server Community and Forums
