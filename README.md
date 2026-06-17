## 📌 Project Overview & Motivation

The business analysis team at Gravity Books faced significant operational bottlenecks due to the lack of a centralized, optimized data source for reporting. Querying the operational database directly led to performance degradation and complex SQL joins that delayed business reports.

### Business Requirements
To enable timely decision-making, the business requested a dedicated **Sales & Delivery Data Mart** to answer key performance indicators (KPIs):
* **Sales Performance:** Monitor `Total Order Price` and `Total Fee` (Order Price + Shipping Cost) aggregated by Month, Quarter, Shipping Method, Author, and Customer Country.
* **Fulfillment Efficiency:** Track logistics efficiency via the `Average Days of Process` (handling time) and `Average Days to Deliver` per Shipping Method.

---

## 📐 Data Modeling Architecture

The project implements a **Kimball Architecture** using a **Galaxy Schema** (or Fact Constellation) containing two distinct fact tables to address different grains of business analysis.

### 1. Conceptual Modeling (Source OLTP)
The source operational database consists of a normalized relational schema tracking customers, orders, order histories, books, authors, publishers, and shipping details. 

### 2. Logical & Physical Warehousing Design (OLAP)
The data mart uses a Galaxy Schema structure to separate sales transactions from logistics snapshots while sharing conformed dimensions:

* **Fact Tables:**
    * `Orders_Fact` (Transactional Fact): Tracks individual sales transactions down to the order line grain. Measures include `Order_Price` and `Total_Fee`.
    * `Order_History_Fact` (Accumulating Snapshot Fact): Tracks the lifecycle of an order across multiple fulfillment milestones. Measures include `Days_of_Process` and `Days_of_Deliver`.
* **Dimension Strategies & Types:**
    * **Conformed & Role-Playing Dimension:** `Date_Dim` acts as a conformed dimension across both facts and role-plays into multiple date keys (`Received_Date_Key`, `Pending_Date_Key`, `In_Progress_Date_Key`, `Delivered_Date_Key`, `Cancelled_Date_Key`, `Returned_Date_Key`) within the accumulating snapshot fact.
    * **Slowly Changing Dimension (SCD Type 2):** Implemented for `Shipping_Dim` using fields `Start_Date`, `End_Date`, and `Is_Current` to accurately track historical fluctuations in shipping costs over time.
    * **Junk Dimension:** `Status_Dim` consolidates low-cardinality flags and state attributes (`Status_Value`, `Status_Category`, `is_terminal_State`) into a single dimension to eliminate messy foreign keys in the fact table.
    * **Degenerate Dimensions:** `OrderID_DD` and `LineID_DD` are stored directly within `Orders_Fact` for deep transactional drill-downs without dimension table overhead.
    * **Snowflake Dimensions:** Handles many-to-many relationships naturally present in the business logic (e.g., Bridge tables for `Book_Author_Dim` linking books to multiple authors, and `Customer_Address_Dim` linking customers to multiple addresses).

---

## ⚙️ ETL / ELT Pipeline (SSIS)

Data integration and orchestration from the OLTP source to the OLAP destination are handled entirely via **SQL Server Integration Services (SSIS)**. 

### SSIS Project Structure (`GBs_DWH`)
Individual packages were developed modularly for extraction, cleaning, surrogate key lookup, and loading:
* `Date_Dim` & `Time_Dim` (Pre-populated master dimensions)
* `Author_Dim_v001.dtsx` / `Books_Dim_v001.dtsx` / `Book_Author_dim_v001.dtsx`
* `Customer_Dim_v001.dtsx` / `Address_Dim_v001.dtsx` / `Customer_Address_Dim_v001.dtsx`
* `Shipping_Dim_v001.dtsx` (SCD Type 2 logic handling)
* `Status_Dim(Junk).v001.dtsx`
* `Orders_Fact_v001.dtsx` (Transactional ingestion pipeline with datetime splitting and lookup transformations)
* `Order_History_Fact_v001.dtsx` (Accumulating snapshot loader that maps sequential status transitions to unified milestones)

### Ingestion Flow Mechanics
1.  **Extraction:** OLE DB Sources ingest transactional records from the operational schema.
2.  **Transformation:** Derived Column transformations split compound date-time values, compute metrics like `Total_Fee`, and execute conditional status mappings.
3.  **Surrogate Key Mapping:** Cascading Lookup transformations map operational business keys (BK) to warehouse surrogate keys (SK) before fact ingestion.
4.  **Loading:** OLE DB Destinations write into the physical DWH storage layer using bulk-load configuration options.

---

## 🧊 Multi-Dimensional Modeling (SSAS)

To optimize query execution and support high-speed aggregations, the data warehouse is abstracted into analytical cubes using **SQL Server Analysis Services (SSAS)**.

* **Cube 1: Sales Analysis Cube**
    * *Measures:* `Total Fee`, `Total Order Price`
    * *Dimensions:* `Date_Dim` (Month, Quarter hierarchies), `Shipping_Dim`, `Book_Dim` (Author snowflake), `Address_Dim` (Country level).
* **Cube 2: Logistics & Delivery Cube**
    * *Measures:* `Average Days of Process`, `Average Days to Deliver`
    * *Dimensions:* `Shipping_Dim` (analyzing performance vectors across different carriers).

---

## 📊 Business Intelligence Dashboard (Power BI)

An interactive analytics dashboard built on **Power BI** serves the final presentation layer, bringing the data mart insights to business stakeholders.

### Key Insights & KPI Layouts:
* **Executive Scorecard:** Highlights a **Total Revenue of $326.58K** within the tracked period.
* **Temporal Trends:** Line charts plotting `Total Fee by Month` expose seasonal sales volume spikes and drops.
* **Logistics Visualizations:** Donut charts breakdown order patterns (e.g., `Total Fee by Day and Night` interactions), while clustered column charts compare carrier financial impact (`Total Fee and Order Price by Method Name`).
* **Geographic and Author Performance:** Horizontal bar charts rank the **Top 10 Countries by Sales** (with China and Indonesia leading) and highlight top-performing authors based on revenue margins.

---

## ⏳ Automation & Scheduling

The enterprise environment relies on continuous updates automated via **SQL Server Agent Jobs**.

* **Job Name:** `integrate data into GBs DWH`
* **Execution Strategy:** Multi-step sequencing enforcing dependency rules (Dimensions are successfully loaded in steps 1-7 before Fact loading begins in steps 8-11. Step 12 handles post-processing history fact logic).
* **Schedule:** Configured as a recurring daily routine executing automatically at **10:05:00 PM** to ensure the reporting dashboard is fresh at the start of every business morning.

---

## 📁 Repository Structure
