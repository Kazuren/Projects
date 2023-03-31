from app import create_app, db
from app.models import User, Review, Game, Upvote, Platform, Category, Developer, Task, Notification, Message

app = create_app()

@app.shell_context_processor
def make_shell_context():
  return {'db': db, 'User': User, 'Review': Review, 'Game': Game, 
    'Upvote': Upvote, 'Platform': Platform, 'Category': Category, 
    'Developer': Developer, 'Task': Task, 'Notification': Notification, 'Message': Message}
