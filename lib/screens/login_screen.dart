import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import 'task_home_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool isPasswordHidden = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Consumer<LoginViewModel>(
            builder: (context, viewModel, child) {
              final bottomInset = MediaQuery.of(context).viewInsets.bottom;

              return Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF0F4F8), Color(0xFFD9E2EC)],
                  ),
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      // Ensures the content can expand to at least the viewport
                      // height (helps centering on large screens).
                      minHeight:
                          MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          Expanded(
                            child: Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Icon
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE1F0FF),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.shield,
                                        color: Color(0xFF007AFF),
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    const Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Welcome back to Planno. Please enter your details.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    if (viewModel.errorMessage != null) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.red.shade200,
                                          ),
                                        ),
                                        child: Text(
                                          viewModel.errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 32),
                                    // Email Field
                                    TextField(
                                      controller: _emailController,
                                      onChanged: (value) {
                                        viewModel.email = value;
                                        if (viewModel.errorMessage != null &&
                                            value.isNotEmpty) {
                                          viewModel.errorMessage = null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.email_outlined,
                                        ),
                                        hintText: "hello@example.com",
                                        filled: true,
                                        fillColor: const Color(0xFFF7FAFC),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Password Field
                                    TextField(
                                      controller: _passwordController,
                                      obscureText: isPasswordHidden,
                                      onChanged: (value) {
                                        viewModel.password = value;
                                        if (viewModel.errorMessage != null &&
                                            value.isNotEmpty) {
                                          viewModel.errorMessage = null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                        ),
                                        suffixIcon: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: Icon(
                                            isPasswordHidden
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: Colors.grey.shade400,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordHidden =
                                                  !isPasswordHidden;
                                            });
                                          },
                                        ),
                                        hintText: "••••••••••",
                                        filled: true,
                                        fillColor: const Color(0xFFF7FAFC),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    // Forgot Password
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const ForgotPasswordScreen(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "Forgot Password?",
                                          style: TextStyle(
                                            color: Color(0xFF007AFF),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Sign In Button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 56,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF4A5568,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        onPressed: viewModel.isLoading
                                            ? null
                                            : () async {
                                                final success = await viewModel
                                                    .login();
                                                if (success &&
                                                    context.mounted) {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const TaskDashboard(),
                                                    ),
                                                  );
                                                }
                                              },
                                        child: viewModel.isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Sign In",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.arrow_forward,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: bottomInset > 0 ? 16 : 40,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account? "),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      color: Color(0xFF007AFF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
