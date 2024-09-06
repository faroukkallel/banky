class _WithdrawPageState extends State<WithdrawPage> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final List<String> _paymentMethods = ['Credit Card', 'PayPal', 'Bank Transfer'];
  String _selectedPaymentMethod = 'Select payment method';
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  late User _currentUser;
  double _balance = 0.0; // State variable for balance

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
      _currentUser = FirebaseAuth.instance.currentUser!;

      final userDocRef = FirebaseFirestore.instance.collection('users').doc(_currentUser.uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists) {
        setState(() {
          _balance = (userDoc['balance'] as int).toDouble(); // Convert to double for UI
        });
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Withdraw Funds'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              // Show information about the withdrawal process
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserProfile(),
            SizedBox(height: 20),
            _buildSectionTitle(context, 'Amount'),
            _buildAmountInputField(),
            SizedBox(height: 20),
            _buildSectionTitle(context, 'Payment Method'),
            _buildPaymentMethodField(context),
            SizedBox(height: 20),
            FadeTransition(
              opacity: _buttonAnimation,
              child: _buildWithdrawButton(context),
            ),
            SizedBox(height: 20),
            _buildInstructions(),
          ],
        ),
      ),
    );
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
              _currentUser.displayName ?? 'John Doe',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Available Balance: \$${_balance.toStringAsFixed(2)}', // Display balance dynamically
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }
}
