# Portfolio

## Introduction
Afif Mazhar is a seasoned economist/data scientist with **2+ years of experience in data science modeling**. He has worked for 2 years as a lead graduate research assistant in economics working on quasi-experimental research design methods in causal inference. Afif has a paper that has been accepted to the [APPAM 2024 conference](https://www.appam.org/conference-events/fall-research-conference/2024appam/) (invitation to present - declined) and the [IIOC 2025 conference](https://www.indorgsociety.org/conference) (live presentation and panel discussant). Afif is a data scientist/engineer at AT&T, working at the forefront of optimizing Generative AI as prime solutions to applications across AT&T. Afif work on two teams: the Intelligent Automation Marketplace and the AI/ML team part of the Automations Platform Development organization. His past projects include developing data pipelines for AskAT&T, creating dashboards for users on Power Platforms, and migrating legacy data systems to new platforms. His current projects revolve around creating AI Agents to automate and enhance existing applications. He is primarily interested in how agentic systems can influence decision-making across AT&T. Afif routinely blends economic theory in his projects as a supplement to enhancing his product. Afif's recent project through Palantir AIP and Foundry has been accepted to the AT&T Software Symposium 2025 (10% acceptance rate). The project focuses on using association rules to correlate network tickets/alarms and identifying root causes of failure.


## Skills
Afif's interests include **causal inference, experimentation, time series and machine learning** - all at scale in production environments.\
Afif's tools of use include **python, pyspark, DataBricks, PowerBI, SQL, Palantir Foundry, STATA, R.**\
Afif's specific modeling techniques used include **supervised learning (logistic regression, linear regression, decision trees, XGBoost), causal inference (difference-in-differences, synthetic control), unsupervised learning (a priori rules, k-means clustering), and time series (AR, MA, LSTM, ARIMA, VAR, Prophet, XGBoost).**

A quick rundown of major projects:

## [Cannabis Event Study](https://github.com/afifmazhar/Portfolio/tree/main/Data%20Science%20Projects/Econometrics/Cannabis%20Event%20Study)
"Cannabis: Legalization and the Economic Effects"

Used a staggered difference-in-differences model with heterogenous-robust estimators that are prevalent in the literature to understand the effects of marijuana legalization by policy passage. Collected data on GDP, household income, and poverty rates. (Python, STATA)

## [Credit Risk](https://github.com/afifmazhar/Portfolio/tree/main/Data%20Science%20Projects/Machine%20Learning/Credit%20Risk)
Binary classification model that predicts whether a customer will pay off their loan. Used various models (XGBoost, Decision Trees, Gaussian) and selected XGBoost with 92% accuracy rate. (Python - sci-kit learn)

## [Detecting and Preventing SIM Swap Fraud in Telecom Networks (WIP)](https://github.com/afifmazhar/Portfolio/tree/main/Data%20Science%20Projects/Machine%20Learning/Credit%20Risk)
(WIP) Use call detail records (CDRs) and Cell Tower Locations to identify SIM swaps. Use supervised learning models (Random Forest, XGBoost) to classify fraud vs non-fraud. Apply clustering (K-Means, Hierarchial, DBSCAN) to detect suspicious groups of users. Run anomaly detection (Isolation Forest, Autoencoders) to flag potential fraud cases. Use DID (difference-in-differences) or uplift modeling to estimate impact of fraud detection measures. Output in dashboards/reports to highlight business impact.

## The Causal Effect of Online Ads on Sales (WIP)
(WIP) Use Google Ads public datasets to identify if paid ads provide more sales or would customers have bought the product anyways. Methods include uplift modeling, a/b testing, and regression discontinuity design. Deployment will be a web application that marketers can analyze their campaign data and get causal insights.

## [College Enrollment by Race based on Macroeconomic Indicators](https://github.com/afifmazhar/Portfolio/tree/main/Data%20Science%20Projects/Econometrics/College%20Enrollment)

I construct a SVAR model based on [Ewing, Beckert, and Ewing 2009](https://github.com/afifmazhar/Portfolio/blob/main/Data%20Science%20Projects/Econometrics/College%20Enrollment/References/Ewing_Beckert_2009.pdf) that extends the general premise of the paper. The original SVAR model included two macroeconomic indicators (economic growth and inflation); I add unemployment rate to measure how college enrollment by race is affected by macroeconomic shocks measured by impulse response functions (IRF). I find "white" students are less likely to enroll in college in the fall and that "minority" students are more likely to enroll in college in the fall.
