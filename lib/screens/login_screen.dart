import 'package:crm/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:crm/utils/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isHoveringGoogle = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('remembered_username');
    if (savedUsername != null) {
      setState(() {
        _usernameCtrl.text = savedUsername;
        _rememberMe = true;
      });
    }
  }

  Future<void> _handleRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString(
        'remembered_username',
        _usernameCtrl.text.trim(),
      );
    } else {
      await prefs.remove('remembered_username');
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final result = await auth.loginWithUsername(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    } else {
      await _handleRememberMe();
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

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
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isDesktop
                    ? _buildWideLayout(context)
                    : _buildNarrowLayout(context),
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
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/illustration.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 28),
        Expanded(flex: 4, child: _buildLoginCard(context)),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/illustration.png',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 18),
          _buildLoginCard(context),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final enableHover = kIsWeb && Responsive.isDesktop(context);

    return Container(
      padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 28),
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
            const Icon(Icons.bubble_chart, color: Colors.white),
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

          _label('Username'),
          _textField(_usernameCtrl, 'User123!'),

          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: _label('Password')),
            TextButton(
              onPressed: _usernameCtrl.text.isEmpty
                  ? null
                  : () async {
                      final auth = context.read<AuthProvider>();
                      final result =
                          await auth.sendPasswordResetByUsername(
                        _usernameCtrl.text.trim(),
                      );
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(result ?? 'Password reset email sent'),
                        ),
                      );
                    },
              child: const Text('Forgot Password?'),
            )
          ]),

          _passwordField(),

          const SizedBox(height: 12),

          Row(children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
              activeColor: Colors.tealAccent.shade400,
              checkColor: Colors.black,
            ),
            const Text('Remember Me',
                style: TextStyle(color: Colors.white)),
          ]),

          const SizedBox(height: 12),

          _loginButton(),

          const SizedBox(height: 16),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('New on our Platform?',
                style: TextStyle(color: Colors.white70)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Create an Account'),
            ),
          ]),

          const SizedBox(height: 12),
          const Text('or', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 12),

          MouseRegion(
            onEnter:
                enableHover ? (_) => setState(() => _isHoveringGoogle = true) : null,
            onExit:
                enableHover ? (_) => setState(() => _isHoveringGoogle = false) : null,
            child: GestureDetector(
              onTap: () async {
                final auth = context.read<AuthProvider>();
                final result = await auth.signInWithGoogle();
                if (!mounted) return;
                if (result == null) {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                } else {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(result)));
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                      _isHoveringGoogle ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Image.asset('assets/google_logo.png', height: 28),
                  const SizedBox(width: 12),
                  const Text('Sign in with Google',
                      style: TextStyle(color: Colors.white)),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _textField(TextEditingController c, String hint) =>
      TextFormField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(hint),
        validator: (v) =>
            v == null || v.isEmpty ? 'Required field' : null,
      );

  Widget _passwordField() => TextFormField(
        controller: _passwordCtrl,
        obscureText: !_isPasswordVisible,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(
          '********',
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
        validator: (v) =>
            v == null || v.isEmpty ? 'Password required' : null,
      );

  Widget _loginButton() => SizedBox(
        width: double.infinity,
        height: 54,
        child: Consumer<AuthProvider>(
          builder: (_, auth, __) => ElevatedButton(
            onPressed: auth.isLoading ? null : _onLoginPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              elevation: 6,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3DD3C9), Color(0xFF2A9DF4)],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(
                child: auth.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator.adaptive(),
                      )
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
      );

  InputDecoration _inputDecoration(String hint, {Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
