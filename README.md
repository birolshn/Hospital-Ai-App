# 🏥 Hospital Bed Occupancy Prediction App

A machine learning–powered system for predicting hospital bed occupancy rates based on staffing levels, patient admissions, and service-level data.

This project demonstrates a complete workflow from data analysis and model training (Colab) to deployment via FastAPI and mobile integration using Flutter.

# 📚 Overview

This project uses a synthetic dataset that simulates real hospital operations — including staff schedules, patient admissions, and bed management.
It builds a Random Forest Regression model to predict hospital occupancy rates weekly.

The backend exposes a REST API (FastAPI) for real-time predictions, and the frontend (Flutter app) allows users to enter hospital statistics and instantly see the predicted occupancy.

# 🧠 Machine Learning Model

Framework: scikit-learn

Model: RandomForestRegressor

Goal: Predict occupancy_rate (proxy = patients_admitted / available_beds)

Evaluation:

- MAE: 0.0341

- RMSE: 0.0785

- R²: 0.53

These results show that the model achieves low average error and explains over 50% of data variance — a strong baseline for operational forecasting.
