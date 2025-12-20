import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/models/auth.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  
  bool _isSignup = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    if (_isSignup) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
        );
        return;
      }

      final success = await authProvider.signup(
        SignupRequest(
          username: _usernameController.text,
          password: _passwordController.text,
          email: _emailController.text,
          nom: _nomController.text,
          prenom: _prenomController.text,
        ),
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscription réussie ! Vous pouvez maintenant vous connecter.')),
        );
        setState(() {
          _isSignup = false;
          _usernameController.clear();
          _passwordController.clear();
          _emailController.clear();
          _nomController.clear();
          _prenomController.clear();
          _confirmPasswordController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Échec de l\'inscription')),
        );
      }
    } else {
      final success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        widget.onLoginSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.error ?? 'Échec de la connexion')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F9FF), // blue-50
              Colors.white,
              Color(0xFFF0FDFA), // teal-50
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Title
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B6FB0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CHU Santé',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tableau de bord financier',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4B5563),
                  ),
                ),
                const SizedBox(height: 32),

                // Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignup ? 'Créer un compte' : 'Se connecter',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(height: 24),

                        // Signup Fields
                        if (_isSignup) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _nomController,
                                  label: 'Nom',
                                  placeholder: 'Dupont',
                                  validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  controller: _prenomController,
                                  label: 'Prénom',
                                  placeholder: 'Jean',
                                  validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildTextField(
                          controller: _usernameController,
                          label: 'Nom d\'utilisateur',
                          placeholder: 'jdupont',
                          prefixIcon: Icons.person_outline,
                          validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                        ),
                        const SizedBox(height: 16),

                        if (_isSignup) ...[
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email',
                            placeholder: 'jean.dupont@chu.fr',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v?.contains('@') != true ? 'Email invalide' : null,
                          ),
                          const SizedBox(height: 16),
                        ],

                        _buildTextField(
                          controller: _passwordController,
                          label: 'Mot de passe',
                          placeholder: '••••••••',
                          isObscure: _obscurePassword,
                          onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) => (v?.length ?? 0) < 6 ? 'Min. 6 caractères' : null,
                        ),
                        const SizedBox(height: 16),

                        if (_isSignup)
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirmer',
                            placeholder: '••••••••',
                            isObscure: _obscureConfirmPassword,
                            onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            validator: (v) => v?.isEmpty == true ? 'Requis' : null,
                          ),
                        
                        if (!_isSignup) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Mot de passe oublié ?', style: TextStyle(color: Color(0xFF0B6FB0))),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Remember me visual
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: false, 
                                  activeColor: const Color(0xFF0B6FB0),
                                  onChanged: (v) {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Se souvenir de moi', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],

                        const SizedBox(height: 24),

                        Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading ? null : () => _handleSubmit(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0B6FB0),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text(
                                        _isSignup ? 'Créer mon compte' : 'Se connecter',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignup = !_isSignup;
                      _formKey.currentState?.reset();
                      _usernameController.clear();
                      _passwordController.clear();
                      _emailController.clear();
                      _nomController.clear();
                      _prenomController.clear();
                      _confirmPasswordController.clear();
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      text: _isSignup ? 'Vous avez déjà un compte ? ' : 'Vous n\'avez pas de compte ? ',
                      style: const TextStyle(color: Color(0xFF4B5563)),
                      children: [
                        TextSpan(
                          text: _isSignup ? 'Se connecter' : 'Créer un compte',
                          style: const TextStyle(
                            color: Color(0xFF0B6FB0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  '© 2025 CHU Santé. Tous droits réservés.',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    bool isObscure = false,
    VoidCallback? onToggleObscure,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: Colors.grey[400]) : null,
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    icon: Icon(isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: Colors.grey[400]),
                    onPressed: onToggleObscure,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0B6FB0)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
