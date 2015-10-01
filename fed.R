# Macroeconomics.
# More indicators at
#http://en.wikipedia.org/wiki/Federal_Reserve_Economic_Data
#http://fossies.org/linux/gretl/share/bcih/fedstl.idx
ticker_list <- c(
  # Interest rates of different maturities and credit spreads
  'AAA',          # Moody's Seasoned Aaa Corporate Bond Yield©
  'BAA',          # Moody's Seasoned Baa Corporate Bond Yield
  'MORTG',        # 30-Year Conventional Mortgage Rate
  'GS1',          # 1-Year Treasury Constant Maturity Rate
  'GS10',         # 10-Year Treasury Constant Maturity Rate
  'GS20',         # 20-Year Treasury Constant Maturity Rate
  'DTB3',         # 3-Month Treasury Bill: Secondary Market Rate
  'TB1YR',        # 1-Year Treasury Bill: Secondary Market Rate
  # Business conditions
  'INDPRO',       # Industrial Production Index
  'BUSINV',       # Total Business Inventories
  'ISRATIO',      # Total Business: Inventories to Sales Ratio
  'PPIENG',       # Producer Price Index by Commodity Fuels & Related
  #   Products & Power
  'PPIACO',       # Producer Price Index for All Commodities
  'TCU',          # Capacity Utilization: Total Industry
  'NAPM',         # ISM Manufacturing: PMI Composite Index
  # Employment
  'AWHI',         # Aggregate Weekly Hours: Production and Nonsupervisory Employees:
  #   Total Private Industries
  'UNRATE',       # Civilian Unemployment Rate
  'EMRATIO',      # Civilian Employment-Population Ratio
  'LNS14100000',  # Unemployment Rate - Full-Time Workers
  # Others
  'ALTSALES',     # Light Weight Vehicle Sales: Autos & Light Trucks
  'AMBNS',        # Adjusted Monetary Base
  'AMBSL',        # St. Louis Adjusted Monetary Base
  'FEDFUNDS',     # Effective Federal Funds Rate, %
  'GASPRICE',     # Natural Gas Price: Henry Hub, LA© (DISCONTINUED)
  'NPPTTL',       # Total Nonfarm Private Payroll Employment
  'OILPRICE',     # Spot Oil Price: West Texas Intermediate (DISCONTINUED SERIES)
  'PAYEMS',       # All Employees: Total nonfarm
  'TB3MS'         # 3-Month Treasury Bill: Secondary Market Rate
)
