class _WithdrawPageState extends State<WithdrawPage> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final List<String> _paymentMethods = ['Credit Card', 'PayPal', 'Bank Transfer'];
  String _selectedPaymentMethod = 'Select payment method';
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  User? _currentUser;
  double _balance = 0.0;
  String _displayName = 'User'; // Added variable to store display name

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser != null) {
        _fetchUserData(); // Changed method name to reflect fetching of both data
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  Future<void> _fetchUserData() async { // Merged balance and displayName fetching
    if (_currentUser == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid);

    try {
      final userDoc = await userDocRef.get();
      if (userDoc.exists) {
        setState(() {
          _balance = (userDoc['balance'] as int).toDouble(); // Convert int to double for consistency
          _displayName = userDoc['displayName'] ?? 'User'; // Fetch display name
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Widget _buildUserProfile() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.person, color: Colors.white, size: 36),
          radius: 30,
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _displayName, // Use the fetched display name
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Available Balance: \$${_balance.toStringAsFixed(0)}', // Display as integer
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

// The rest of your code remains unchanged...
}
