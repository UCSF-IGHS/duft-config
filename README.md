# LABVISUAL INSTALLATION GUIDE – DUFT Version

## Prerequisites

- SQL Server
- SQL Server Management Studio (SSMS)
- LABVISUAL – DUFT Executable

---

## 🛠️ Step 1: Install SQL Server and SSMS

1. **Download and install** SQL Server and SQL Server Management Studio manually.
2. **Open SSMS** and log in using **Windows Authentication**.

---

## 🔐 Step 2: Enable SQL Login Credentials

1. In SSMS:
   - Expand **Security**
   - Expand **Logins**
   - Right-click on `sa` → **Properties**
   - Under **Status**, in the **Login** section:
     - Set **Enabled**
     - Click **OK**
2. **Restart SQL Server Service**
3. Log out and log back in using:
   - **SQL Server Authentication**
   - **Username**: `sa`
   - **Password**: `root.R00T`

---

## 🌐 Step 3: Enable TCP/IP

1. Launch **SQL Server Configuration Manager**
2. Navigate to:
   - **SQL Server Network Configuration**
   - **Protocols for [YourInstanceName]**
3. Right-click **TCP/IP** → Select **Enable**
4. Right-click **TCP/IP** → **Properties** → Go to **IP Addresses**
   - Scroll to **IPAII**
   - Ensure **TCP Port** is set (default is **1433**)
5. Click **Apply**, then **OK**
6. **Restart SQL Server Service**

---

## 💾 Step 4: Install DUFT Desktop Application

- Run the provided **executable file** to install the LABVISUAL – DUFT desktop platform.

---

## ⚙️ Step 5: Configure Databases

Open the installed DUFT platform and follow these steps:

### Configure Analysis Database (`lab_visual_analysis`)

1. On the side navigation bar, select **Settings**
2. Click **Analysis Database**
3. Enter connection credentials
4. Click **Save**

### Configure Source Database (`labdashdb`)

1. On the side navigation bar, select **Settings**
2. Select **MySQL Database**
3. Enter connection credentials
4. Click **Save**

---

## 🔄 Step 6: Run Data Transformation

1. On the sidebar, click **Refresh Data** → **Execute**
2. Wait for the task to complete
3. Close the dialog box

---

## 📊 Step 7: Confirm Visualization

- Ensure data is now being displayed on the dashboards.

---

✅ **You have successfully set up LABVISUAL – DUFT!**
