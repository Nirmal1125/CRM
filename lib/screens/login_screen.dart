
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  // Hover animation vars
  bool _isHoveringGoogle = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width >= 900;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0F172A).withOpacity(0.95),
                const Color(0xFF0B2545).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child:
                    isWide ? _buildWideLayout(context) : _buildNarrowLayout(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.all(32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.asset(
                    'assets/illustration.png',
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 28),

        Expanded(
          flex: 4,
          child: _buildLoginCard(context),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: double.infinity,
                height: 300,
                child: Image.asset(
                  'assets/illustration.png',
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _buildLoginCard(context),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.06),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bubble_chart, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(
              'GrowConnect CRM',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ]),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Username',
              style: GoogleFonts.openSans(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 6),

          TextFormField(
            controller: _usernameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(hintText: 'User123!'),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter username'
                : null,
          ),

          const SizedBox(height: 16),

          Row(children: [
            Expanded(
              child: Text(
                'Password',
                style: GoogleFonts.openSans(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Forgot Password?',
                  style: TextStyle(color: Colors.white.withOpacity(0.8))),
            ),
          ]),

          const SizedBox(height: 6),

          TextFormField(
            controller: _passwordCtrl,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              hintText: '********',
              suffix: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter password';
              if (v.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          const SizedBox(height: 12),

          Row(children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (val) =>
                  setState(() => _rememberMe = val ?? false),
              activeColor: Colors.tealAccent.shade400,
              checkColor: Colors.black,
            ),
            const SizedBox(width: 6),
            Text('Remember Me',
                style: TextStyle(color: Colors.white.withOpacity(0.9))),
          ]),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onLoginPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 6,
                backgroundColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF3DD3C9), Color(0xFF2A9DF4)]),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator.adaptive())
                      : Text(
                          'Sign In',
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('New on our Platform?',
                style: TextStyle(color: Colors.white.withOpacity(0.7))),
            TextButton(
              // NAVIGATE to Sign Up screen
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Create an Account'),
            ),
          ]),

          const SizedBox(height: 6),

          Row(children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text('or', style: TextStyle(color: Colors.white.withOpacity(0.6))),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
          ]),

          const SizedBox(height: 14),

          // ⭐ GOOGLE BUTTON WITH HOVER ANIMATION ⭐
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveringGoogle = true),
            onExit: (_) => setState(() => _isHoveringGoogle = false),
            child: AnimatedScale(
              scale: _isHoveringGoogle ? 1.07 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Google sign-in tapped')),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(_isHoveringGoogle ? 0.12 : 0.08),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    boxShadow: _isHoveringGoogle
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/google_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, Widget? suffix}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      suffixIcon: suffix != null
          ? Padding(padding: const EdgeInsets.only(right: 8.0), child: suffix)
          : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
      ),
    );
  }
}
