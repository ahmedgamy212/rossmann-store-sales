# Rossmann Store Sales

End-to-end analysis and sales forecasting for the Rossmann Store Sales dataset. The project combines exploratory data analysis, feature engineering, regression models, SQL analysis, and a Power BI dashboard.

## Project Contents

```text
rossmann-store-sales/
├── Python/
│   ├── rossmann-store-sales.ipynb   # Data preparation, modeling, and predictions
│   ├── train.csv                    # Training data
│   ├── test.csv                     # Test data
│   ├── store.csv                    # Store metadata
│   ├── train_merged.csv             # Training data after the store merge
│   ├── best_xgb_model.pkl           # Trained XGBoost model
│   ├── best_params.json             # Random Forest parameters
│   ├── best_xgb_params.json         # XGBoost parameters
│   ├── xgb_search_results.csv       # Hyperparameter search results
│   ├── submission_xgb.csv           # XGBoost predictions
│   └── submission_final.csv         # Final prediction file
├── SQL/
│   └── SQLQuery1.sql                # Store, promotion, holiday, and trend analysis
├── Power BI/
│   ├── new.pbix                     # Power BI report
│   └── Screenshot *.png             # Report screenshots
└── .gitignore
```

## Analysis and Feature Engineering

The notebook:

- Loads the Rossmann train, test, and store metadata files.
- Merges store metadata into the train and test datasets.
- Removes closed stores from the training data and fills missing test-store status as open.
- Applies `log1p` to sales for modeling.
- Extracts year, month, day, ISO week, and weekend features from `Date`.
- Identifies whether a date falls inside a store's promotion interval.
- Calculates the number of months since a store's competition opened.
- One-hot encodes store type, assortment, state holiday, and promotion interval.
- Splits the data chronologically into 80% training and 20% validation sets.
- Fills remaining missing feature values with `-1`.

## Models

Three regression approaches are evaluated:

1. Linear Regression as a baseline.
2. Random Forest Regressor with `RandomizedSearchCV`.
3. XGBoost Regressor with `RandomizedSearchCV`.

The target is modeled in log space and converted back to sales values with `expm1`. The selected XGBoost configuration is saved in `best_xgb_params.json`; its trained model is saved as `best_xgb_model.pkl`.

## Running the Notebook

From the `Python` directory, install the required packages:

```bash
pip install pandas numpy matplotlib seaborn scikit-learn xgboost joblib jupyter
```

Then open and run `rossmann-store-sales.ipynb`:

```bash
cd Python
jupyter notebook rossmann-store-sales.ipynb
```

The notebook expects `train.csv`, `test.csv`, and `store.csv` in the same directory. It generates the merged data, trained models, parameter files, search results, and submission CSV files in that directory.

## SQL Analysis

`SQL/SQLQuery1.sql` contains queries for:

- Average sales and customers by store type.
- Best and worst store type by month.
- Store types that are most frequently the weakest performers.
- Promotion-month effects on sales and customers.
- Top and bottom stores by average sales.
- Store-type contribution percentage.
- State and school holiday effects.
- Monthly sales trend and month-over-month change.

The SQL queries expect a table named `train` with the Rossmann training columns and the derived `Year`, `Month`, `StoreType`, and `IsPromoMonth` fields where referenced.

## Power BI

Open `Power BI/new.pbix` in Power BI Desktop to view the dashboard. The accompanying PNG files are previews of the report pages.

## Large Files

`Python/best_rf_model.pkl` is excluded by `.gitignore` because it is larger than GitHub's 100 MB per-file limit. The XGBoost model and the remaining project files are included in the repository. The `train_merged.csv` file is included, but GitHub warns that it is larger than the recommended 50 MB size.

## Data

The project uses the Rossmann Store Sales competition dataset. The source data files are kept in the `Python` directory so the notebook can be run with its relative paths.