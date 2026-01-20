import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';

class CreateEventScreen extends StatefulWidget {
  final String? eventId;

  const CreateEventScreen({super.key, this.eventId});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _capacityController;

  String? _selectedCategory;
  String _visibility = 'Public';
  DateTime? _startTime;
  DateTime? _endTime;

  final List<String> _categories = [
    'Sports',
    'Music',
    'Academic',
    'Social',
    'Workshop',
    'Food',
    'Arts',
    'Tech',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _capacityController = TextEditingController();

    // Load existing event data if editing
    if (widget.eventId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadEventData();
      });
    }
  }

  Future<void> _loadEventData() async {
    if (widget.eventId == null) return;

    try {
      final eventProvider = context.read<EventProvider>();
      await eventProvider.loadEventDetails(widget.eventId!);

      final event = eventProvider.selectedEvent;
      if (event != null && mounted) {
        setState(() {
          _titleController.text = event.title;
          _descriptionController.text = event.description;
          _locationController.text = event.location;
          _capacityController.text = event.capacity.toString();
          _selectedCategory = event.category;
          _visibility = event.visibility;
          _startTime = event.startTime;
          _endTime = event.endTime;
        });
        print(
          '✅ [CreateEventScreen] Event data loaded for editing: ${event.title}',
        );
      }
    } catch (e) {
      print('❌ [CreateEventScreen] Error loading event: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading event: $e')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartTime) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        setState(() {
          if (isStartTime) {
            _startTime = dateTime;
          } else {
            _endTime = dateTime;
          }
        });
      }
    }
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to create an event')),
      );
      return;
    }

    final eventProvider = context.read<EventProvider>();
    final isEditing = widget.eventId != null;
    final existingEvent = isEditing ? eventProvider.selectedEvent : null;

    final event = Event(
      id: widget.eventId ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      startTime: _startTime!,
      endTime: _endTime!,
      location: _locationController.text.trim(),
      imageUrl: existingEvent?.imageUrl,
      hostId: existingEvent?.hostId ?? authProvider.currentUser!.id,
      hostName:
          existingEvent?.hostName ??
          (authProvider.currentUser!.fullName ?? 'Unknown Host'),
      capacity: int.tryParse(_capacityController.text) ?? 0,
      visibility: _visibility,
      isFeatured: existingEvent?.isFeatured ?? false,
      isCancelled: existingEvent?.isCancelled ?? false,
      goingCount: existingEvent?.goingCount ?? 0,
      interestedCount: existingEvent?.interestedCount ?? 0,
      createdAt: existingEvent?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (isEditing) {
        print('✏️ [CreateEventScreen] Updating event: ${event.title}');
        await eventProvider.updateEvent(event.id, event);
        print('✅ [CreateEventScreen] Event updated successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Event updated successfully!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              print(
                '🏠 [CreateEventScreen] Navigating back to admin dashboard',
              );
              context.go('/admin');
            }
          });
        }
      } else {
        print('📝 [CreateEventScreen] Creating event: ${event.title}');
        await eventProvider.createEvent(event);
        print('✅ [CreateEventScreen] Event created successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Event created successfully!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              print('🏠 [CreateEventScreen] Navigating back to home');
              context.go('/home');
            }
          });
        }
      }
    } catch (e) {
      print('❌ [CreateEventScreen] Error caught: $e');
      print('❌ [CreateEventScreen] Full error: ${e.toString()}');
      if (mounted) {
        // Show error dialog instead of just snackbar
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('❌ Error ${isEditing ? 'Updating' : 'Creating'} Event'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event ${isEditing ? 'update' : 'creation'} failed. Details:',
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    e.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Check console logs and verify:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('✓ You are signed in (not guest)'),
                  const Text('✓ Your user role is "admin"'),
                  const Text('✓ RLS policies are configured'),
                  const Text('✓ Database tables exist'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/debug');
                },
                child: const Text('Go to Debug'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId != null ? 'Edit Event' : 'Create Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Event Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _selectedCategory,
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Start Time
              GestureDetector(
                onTap: () => _selectDateTime(context, true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            _startTime == null
                                ? 'Select date & time'
                                : '${_startTime!.toLocal()}'.split('.')[0],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End Time
              GestureDetector(
                onTap: () => _selectDateTime(context, false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Time',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            _endTime == null
                                ? 'Select date & time'
                                : '${_endTime!.toLocal()}'.split('.')[0],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Capacity
              TextFormField(
                controller: _capacityController,
                decoration: InputDecoration(
                  labelText: 'Capacity (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Visibility
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Visibility',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                value: _visibility,
                items: const [
                  DropdownMenuItem(value: 'Public', child: Text('Public')),
                  DropdownMenuItem(value: 'Private', child: Text('Private')),
                  DropdownMenuItem(
                    value: 'University',
                    child: Text('University Only'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => _visibility = value ?? 'Public');
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              Consumer<EventProvider>(
                builder: (context, eventProvider, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: eventProvider.isLoading ? null : _createEvent,
                      child: eventProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Event'),
                    ),
                  );
                },
              ),

              if (context.watch<EventProvider>().errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    context.watch<EventProvider>().errorMessage!,
                    style: TextStyle(color: Colors.red[400]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
