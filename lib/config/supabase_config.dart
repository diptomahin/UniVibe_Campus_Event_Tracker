const String supabaseUrl = 'https://nrplnibyxgkwediopvja.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ycGxuaWJ5eGdrd2VkaW9wdmphIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgwNTMwNjAsImV4cCI6MjA4MzYyOTA2MH0.sZk0G8-17GHBkenrlCXnGlLKCesFNGzDO2vcl_F0AQU';

// Database table names
class DatabaseTables {
  static const String users = 'users';
  static const String events = 'events';
  static const String rsvps = 'rsvps';
  static const String notifications = 'notifications';
  static const String categories = 'categories';
  static const String eventReports = 'event_reports';
}

// Storage bucket names
class StorageBuckets {
  static const String eventImages = 'event-images';
  static const String userAvatars = 'user-avatars';
}
