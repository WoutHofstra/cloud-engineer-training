import os
from datetime import datetime, timezone

from flask import Flask, render_template, request, redirect, session
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash


app = Flask(__name__)

# --------------------------------------------------
# Configuration
# --------------------------------------------------

app.secret_key = os.environ["FLASK_SECRET_KEY"]

app.config["SQLALCHEMY_DATABASE_URI"] = os.environ["DATABASE_URL"]
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)


# --------------------------------------------------
# Database models
# --------------------------------------------------

class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)

    username = db.Column(
        db.String(50),
        unique=True,
        nullable=False
    )

    password_hash = db.Column(
        db.String(255),
        nullable=False
    )

    created_at = db.Column(
        db.DateTime,
        nullable=False,
        default=lambda: datetime.now(timezone.utc)
    )

    messages = db.relationship(
        "Message",
        backref="user",
        lazy=True
    )


class Message(db.Model):
    __tablename__ = "messages"

    id = db.Column(db.Integer, primary_key=True)

    user_id = db.Column(
        db.Integer,
        db.ForeignKey("users.id"),
        nullable=False
    )

    content = db.Column(
        db.Text,
        nullable=False
    )

    created_at = db.Column(
        db.DateTime,
        nullable=False,
        default=lambda: datetime.now(timezone.utc)
    )


# --------------------------------------------------
# Routes
# --------------------------------------------------

@app.route("/")
def index():

    messages = (
        Message.query
        .order_by(Message.created_at.asc())
        .all()
    )

    return render_template(
        "index.html",
        messages=messages,
        username=session.get("username")
    )


@app.route("/register", methods=["POST"])
def register():

    username = request.form["username"].strip()
    password = request.form["password"]

    if not username or not password:
        return "Username and password are required", 400

    # Check whether username already exists
    existing_user = User.query.filter_by(
        username=username
    ).first()

    if existing_user:
        return "Username already exists", 409

    user = User(
        username=username,
        password_hash=generate_password_hash(password)
    )

    db.session.add(user)
    db.session.commit()

    session["user_id"] = user.id
    session["username"] = user.username

    return redirect("/")


@app.route("/login", methods=["POST"])
def login():

    username = request.form["username"].strip()
    password = request.form["password"]

    user = User.query.filter_by(
        username=username
    ).first()

    if user is None:
        return "Invalid username or password", 401

    if not check_password_hash(
        user.password_hash,
        password
    ):
        return "Invalid username or password", 401

    session["user_id"] = user.id
    session["username"] = user.username

    return redirect("/")


@app.route("/logout")
def logout():

    session.clear()

    return redirect("/")


@app.route("/message", methods=["POST"])
def create_message():

    if "user_id" not in session:
        return "You must be logged in", 401

    content = request.form["content"].strip()

    if not content:
        return redirect("/")

    message = Message(
        user_id=session["user_id"],
        content=content
    )

    db.session.add(message)
    db.session.commit()

    return redirect("/")


# --------------------------------------------------
# Start application
# --------------------------------------------------

with app.app_context():
    db.create_all()


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )