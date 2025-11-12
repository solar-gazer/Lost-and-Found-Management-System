import tkinter as tk
from tkinter import ttk, messagebox
import mysql.connector

# ---------------- DATABASE CONNECTION ----------------
def connect_db():
    try:
        db = mysql.connector.connect(
            host="localhost",
            user="admin",          # Change to 'root' if needed
            password="Pesu@123",   # Change to your password
            database="lostandfounddb"
        )
        return db
    except mysql.connector.Error as err:
        messagebox.showerror("Database Error", f"Could not connect:\n{err}")
        return None


# ---------------- LOGIN SCREEN ----------------
def login_screen():
    login = tk.Tk()
    login.title("Login - Lost and Found System")
    login.geometry("400x300")
    login.configure(bg="#f5f5f5")

    tk.Label(login, text="Login to Continue", font=("Segoe UI", 14, "bold"), bg="#f5f5f5").pack(pady=20)
    tk.Label(login, text="User ID").pack()
    entry_uid = tk.Entry(login)
    entry_uid.pack(pady=5)

    tk.Label(login, text="Role (Admin/Student)").pack()
    role_entry = ttk.Combobox(login, values=["Admin", "Student"])
    role_entry.pack(pady=5)

    def login_user():
        uid = entry_uid.get()
        role = role_entry.get()
        db = connect_db()
        if not db:
            return
        cursor = db.cursor()
        cursor.execute("SELECT * FROM user WHERE UserID=%s AND Role=%s", (uid, role))
        user = cursor.fetchone()
        if user:
            login.destroy()
            main_app(uid, role)
        else:
            messagebox.showerror("Error", "Invalid UserID or Role!")

    tk.Button(login, text="Login", command=login_user, bg="#2980b9", fg="white", width=15).pack(pady=20)
    login.mainloop()


# ---------------- MAIN APPLICATION ----------------
def main_app(user_id, role):
    db = connect_db()
    cursor = db.cursor()

    root = tk.Tk()
    root.title("Lost and Found Management System")
    root.geometry("1100x700")
    root.configure(bg="#f7f7f7")

    tk.Label(root, text=f"Lost and Found Management System ({role})", font=("Segoe UI", 18, "bold"), bg="#f7f7f7").pack(pady=20)

    notebook = ttk.Notebook(root)
    notebook.pack(fill="both", expand=True, padx=10, pady=10)

    # ---------------- TAB 1: ADD LOST ITEM ----------------
    tab1 = tk.Frame(notebook, bg="#ffffff")
    notebook.add(tab1, text="➕ Add Lost Item")

    fields = ["Title", "Description", "Category", "Location Lost", "Date Lost (YYYY-MM-DD)"]
    entries = {}

    for i, field in enumerate(fields):
        tk.Label(tab1, text=field, bg="#ffffff").grid(row=i, column=0, padx=10, pady=8, sticky="e")
        e = tk.Entry(tab1, width=40)
        e.grid(row=i, column=1, padx=10, pady=8)
        entries[field] = e

    def add_lost_item():
        try:
            data = (
                entries["Title"].get(),
                entries["Description"].get(),
                entries["Category"].get(),
                entries["Location Lost"].get(),
                entries["Date Lost (YYYY-MM-DD)"].get(),
                user_id,
                1,  # admin id fixed
            )
            cursor.execute("CALL AddLostItem(%s, %s, %s, %s, %s, %s, %s)", data)
            db.commit()
            messagebox.showinfo("Success", "Lost item added successfully!")
            for e in entries.values():
                e.delete(0, tk.END)
        except mysql.connector.Error as err:
            messagebox.showerror("Error", f"{err}")

    tk.Button(tab1, text="Add Lost Item", command=add_lost_item, bg="#2e86de", fg="white").grid(row=len(fields), column=0, columnspan=2, pady=15)

    # ---------------- TAB 2: VIEW / DELETE LOST ITEMS ----------------
    tab2 = tk.Frame(notebook, bg="#ffffff")
    notebook.add(tab2, text="📋 View/Delete Lost Items")

    cols = ("ID", "Title", "Category", "Location", "Date")
    tree = ttk.Treeview(tab2, columns=cols, show="headings", height=15)
    for c in cols:
        tree.heading(c, text=c)
        tree.column(c, width=180)
    tree.pack(fill="both", expand=True, pady=10)

    def refresh_lost_items():
        cursor.execute("SELECT LostItemID, Title, Category, LocationLost, DateLost FROM LostItem")
        rows = cursor.fetchall()
        for i in tree.get_children():
            tree.delete(i)
        for row in rows:
            tree.insert("", tk.END, values=row)

    def delete_lost_item():
        if role == "Student":
            messagebox.showwarning("Access Denied", "Students are not allowed to delete items.")
            return

        selected = tree.focus()
        if not selected:
            messagebox.showwarning("Select", "Select an item to delete!")
            return

        lost_id = tree.item(selected)['values'][0]
        cursor.execute("DELETE FROM LostItem WHERE LostItemID=%s", (lost_id,))
        db.commit()
        messagebox.showinfo("Deleted", f"Lost Item {lost_id} deleted!")
        refresh_lost_items()

    tk.Button(tab2, text="🔄 Refresh", command=refresh_lost_items, bg="#27ae60", fg="white").pack(side="left", padx=20, pady=10)
    tk.Button(tab2, text="🗑 Delete Selected", command=delete_lost_item, bg="#c0392b", fg="white").pack(side="left", padx=10, pady=10)

    # ---------------- TAB 3: MANAGE CLAIMS (ADMIN) ----------------
    if role == "Admin":
        tab3 = tk.Frame(notebook, bg="#ffffff")
        notebook.add(tab3, text="🧾 Manage Claims")

        tk.Label(tab3, text="Claim ID to Approve", bg="#ffffff").grid(row=0, column=0, padx=10, pady=10)
        entry_claimid = tk.Entry(tab3)
        entry_claimid.grid(row=0, column=1, padx=10, pady=10)

        def approve_claim():
            cid = entry_claimid.get()
            try:
                cursor.execute("UPDATE Claim SET Status='Approved', AdminID=%s WHERE ClaimID=%s", (user_id, cid))
                db.commit()
                messagebox.showinfo("Success", f"Claim {cid} approved (Trigger fired).")
            except mysql.connector.Error as err:
                messagebox.showerror("Error", f"{err}")

        tk.Button(tab3, text="Approve Claim", command=approve_claim, bg="#27ae60", fg="white").grid(row=1, column=0, columnspan=2, pady=10)

        def view_approved_claims():
            cursor.execute("""
                SELECT C.ClaimID, U.Name AS Claimant, F.Title AS FoundItem,
                       C.ClaimDate, C.Status
                FROM Claim C
                INNER JOIN `user` U ON C.ClaimantID = U.UserID
                INNER JOIN FoundItem F ON C.FoundItemID = F.FoundItemID
                WHERE C.Status='Approved'
            """)
            rows = cursor.fetchall()
            win = tk.Toplevel(root)
            win.title("Approved Claims")
            tree_claims = ttk.Treeview(win, columns=("ClaimID", "Claimant", "FoundItem", "Date", "Status"), show="headings")
            for c in ("ClaimID", "Claimant", "FoundItem", "Date", "Status"):
                tree_claims.heading(c, text=c)
            tree_claims.pack(fill="both", expand=True, padx=10, pady=10)
            for r in rows:
                tree_claims.insert("", tk.END, values=r)

        tk.Button(tab3, text="📋 View Approved Claims (JOIN)", command=view_approved_claims,
                  bg="#2980b9", fg="white").grid(row=2, column=0, columnspan=2, pady=10)

    # ---------------- TAB 4: NOTIFICATIONS ----------------
    tab4 = tk.Frame(notebook, bg="#ffffff")
    notebook.add(tab4, text="🔔 Notifications")

    notif_cols = ("ID", "UserID", "Message", "DateTime", "Status")
    notif_tree = ttk.Treeview(tab4, columns=notif_cols, show="headings")
    for c in notif_cols:
        notif_tree.heading(c, text=c)
        notif_tree.column(c, width=180)
    notif_tree.pack(fill="both", expand=True, pady=10)

    def load_notifications():
        cursor.execute("SELECT * FROM Notification ORDER BY DateTime DESC")
        rows = cursor.fetchall()
        for i in notif_tree.get_children():
            notif_tree.delete(i)
        for r in rows:
            notif_tree.insert("", tk.END, values=r)

    tk.Button(tab4, text="📩 Load Notifications", command=load_notifications, bg="#2980b9", fg="white").pack(pady=10)

    # ---------------- TAB 5: STATS & COMPLEX QUERIES ----------------
    tab5 = tk.Frame(notebook, bg="#ffffff")
    notebook.add(tab5, text="📊 Stats & Queries")

    tk.Label(tab5, text="Enter User ID", bg="#ffffff").grid(row=0, column=0, padx=10, pady=10)
    entry_uid = tk.Entry(tab5)
    entry_uid.grid(row=0, column=1, padx=10, pady=10)

    def get_total_claims():
        uid = entry_uid.get()
        cursor.execute("SELECT GetTotalClaimsByUser(%s)", (uid,))
        result = cursor.fetchone()
        total = result[0] if result else 0
        messagebox.showinfo("Total Claims", f"User {uid} has made {total} claims.")

    tk.Button(tab5, text="🧮 Check Total Claims (FUNCTION)", command=get_total_claims,
              bg="#e67e22", fg="white").grid(row=1, column=0, columnspan=2, pady=10)

    def view_category_counts():
        cursor.execute("""
            SELECT Category, COUNT(LostItemID) AS TotalLostItems
            FROM LostItem
            GROUP BY Category
            ORDER BY TotalLostItems DESC
        """)
        rows = cursor.fetchall()
        win = tk.Toplevel(root)
        win.title("Lost Items by Category (AGGREGATE)")
        tree = ttk.Treeview(win, columns=("Category", "Total"), show="headings")
        tree.heading("Category", text="Category")
        tree.heading("Total", text="Total Items")
        tree.pack(fill="both", expand=True, padx=10, pady=10)
        for r in rows:
            tree.insert("", tk.END, values=r)

    tk.Button(tab5, text="📊 View Lost Items by Category (AGGREGATE)", command=view_category_counts,
              bg="#16a085", fg="white").grid(row=2, column=0, columnspan=2, pady=10)

    def view_pending_users():
        cursor.execute("""
            SELECT Name FROM user
            WHERE UserID IN (SELECT ClaimantID FROM Claim WHERE Status='Pending')
        """)
        rows = cursor.fetchall()
        win = tk.Toplevel(root)
        win.title("Users with Pending Claims (NESTED)")
        tree = ttk.Treeview(win, columns=("Name",), show="headings")
        tree.heading("Name", text="User Name")
        tree.pack(fill="both", expand=True, padx=10, pady=10)
        for r in rows:
            tree.insert("", tk.END, values=r)

    tk.Button(tab5, text="🧾 View Pending Users (NESTED)", command=view_pending_users,
              bg="#8e44ad", fg="white").grid(row=3, column=0, columnspan=2, pady=10)

    root.mainloop()


# ---------------- RUN APP ----------------
if __name__ == "__main__":
    login_screen()
