# FocusFlow - Flutter Todo App Setup Guide

## Prerequisites

1. **Flutter SDK** - Make sure you have Flutter installed
2. **Supabase Account** - Create a free account at [supabase.com](https://supabase.com)

## Setup Instructions

### 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Choose your organization and enter project details
4. Wait for the project to be created (this may take a few minutes)

### 2. Get Your Supabase Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (looks like: `https://your-project-ref.supabase.co`)
   - **Anon/Public Key** (starts with `eyJ...`)

### 3. Configure Environment Variables

1. Open the `.env` file in the project root
2. Replace the placeholder values with your actual Supabase credentials:

```env
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-actual-anon-key-here
```

### 4. Set Up Database Tables

Run the following SQL in your Supabase SQL Editor to create the required tables:

```sql
-- Create todos table
CREATE TABLE todos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE,
  priority TEXT DEFAULT 'medium',
  color TEXT,
  due_date TIMESTAMP WITH TIME ZONE,
  due_time TEXT,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- Create sub_todos table
CREATE TABLE sub_todos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  todo_id UUID REFERENCES todos(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  completed BOOLEAN DEFAULT FALSE,
  due_date TIMESTAMP WITH TIME ZONE,
  due_time TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;
ALTER TABLE sub_todos ENABLE ROW LEVEL SECURITY;

-- Create policies for todos
CREATE POLICY "Users can view their own todos" ON todos
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own todos" ON todos
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own todos" ON todos
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own todos" ON todos
  FOR DELETE USING (auth.uid() = user_id);

-- Create policies for sub_todos
CREATE POLICY "Users can view sub_todos of their todos" ON sub_todos
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM todos 
      WHERE todos.id = sub_todos.todo_id 
      AND todos.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert sub_todos for their todos" ON sub_todos
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM todos 
      WHERE todos.id = sub_todos.todo_id 
      AND todos.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update sub_todos of their todos" ON sub_todos
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM todos 
      WHERE todos.id = sub_todos.todo_id 
      AND todos.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete sub_todos of their todos" ON sub_todos
  FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM todos 
      WHERE todos.id = sub_todos.todo_id 
      AND todos.user_id = auth.uid()
    )
  );
```

### 5. Install Dependencies and Run

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

## Troubleshooting

### "Supabase credentials not configured" Error

- Make sure your `.env` file has the correct Supabase URL and anon key
- Restart the app after updating the `.env` file
- Check that the values don't contain placeholder text like "your-project-ref"

### Authentication Issues

- Verify that your Supabase project has authentication enabled
- Check that the anon key is correct and hasn't expired
- Make sure Row Level Security policies are set up correctly

### Database Connection Issues

- Ensure your Supabase project is active and not paused
- Verify the project URL is correct
- Check your internet connection

## Features

- ✅ User authentication (sign up/sign in)
- ✅ Create, read, update, delete todos
- ✅ Priority levels (low, medium, high, urgent)
- ✅ Due dates and times
- ✅ Subtasks
- ✅ Tags and filtering
- ✅ Real-time updates
- ✅ Offline-first architecture

## Support

If you encounter any issues, please check:
1. Flutter doctor output
2. Supabase project status
3. Console logs for specific error messages

For additional help, refer to the [Supabase documentation](https://supabase.com/docs) or [Flutter documentation](https://flutter.dev/docs).