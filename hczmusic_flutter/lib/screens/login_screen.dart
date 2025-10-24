import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/user_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsCodeController = TextEditingController();
  bool _isPhoneLogin = false;
  bool _isLoading = false;
  String _smsCode = '';
  int _countdown = 0;
  Timer? _timer;

  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _smsCodeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserLoginResult result;
        if (_isPhoneLogin) {
          // 手机号登录（模拟，因为原API可能不支持短信验证码）
          result = await _apiService.loginByPhone(
            _phoneController.text.trim(),
            _passwordController.text, // 这里模拟用密码字段作为验证码
          );
        } else {
          // 账号密码登录
          result = await _apiService.login(
            _usernameController.text.trim(),
            _passwordController.text,
          );
        }

        if (result.success && result.userInfo != null) {
          // 登录成功，保存用户信息到状态管理器
          final userState = Provider.of<UserState>(context, listen: false);
          await userState.login(
            result.userInfo!.token,
            result.userInfo!.userId,
            result.userInfo!.nickname,
            result.userInfo!.avatar,
          );

          _showSuccessDialog(result.message);
        } else {
          _showErrorDialog(result.message);
        }
      } catch (e) {
        _showErrorDialog('登录失败: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendSmsCode() async {
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^1[3-9]\d{9}).hasMatch(phone)) {
      _showErrorDialog('请输入正确的手机号码');
      return;
    }

    // 模拟发送短信验证码
    setState(() {
      _smsCode = (100000 + (900000 * (1 - 0.1)).toInt()).toString();
      _countdown = 60;
    });

    // 启动倒计时
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _timer?.cancel();
      }
    });

    // 这里实际应该是调用API发送短信
    print('发送短信验证码到: $phone, 验证码: $_smsCode');
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登录成功'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 关闭对话框
              Navigator.of(context).pop(); // 返回上一页
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登录失败'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '欢迎使用HczMusic',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              
              // 登录方式切换
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_isPhoneLogin) {
                            setState(() {
                              _isPhoneLogin = false;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isPhoneLogin 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '账号密码登录',
                              style: TextStyle(
                                color: !_isPhoneLogin 
                                    ? Colors.white 
                                    : Colors.black54,
                                fontWeight: !_isPhoneLogin 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (!_isPhoneLogin) {
                            setState(() {
                              _isPhoneLogin = true;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isPhoneLogin 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              '手机号登录',
                              style: TextStyle(
                                color: _isPhoneLogin 
                                    ? Colors.white 
                                    : Colors.black54,
                                fontWeight: _isPhoneLogin 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 用户名/手机号输入框
              if (!_isPhoneLogin)
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名/邮箱',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入用户名';
                    }
                    return null;
                  },
                )
              else
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '手机号',
                    prefixIcon: const Icon(Icons.phone),
                    border: const OutlineInputBorder(),
                    suffixIcon: _countdown > 0
                        ? TextButton(
                            onPressed: null,
                            child: Text(
                              '${_countdown}秒后重发',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : TextButton(
                            onPressed: _sendSmsCode,
                            child: const Text(
                              '获取验证码',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入手机号';
                    }
                    if (!RegExp(r'^1[3-9]\d{9}).hasMatch(value)) {
                      return '请输入正确的手机号';
                    }
                    return null;
                  },
                ),
              
              const SizedBox(height: 16),

              // 密码/验证码输入框
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPhoneLogin,
                decoration: InputDecoration(
                  labelText: _isPhoneLogin ? '验证码' : '密码',
                  prefixIcon: Icon(_isPhoneLogin ? Icons.lock : Icons.lock),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _isPhoneLogin ? '请输入验证码' : '请输入密码';
                  }
                  if (!_isPhoneLogin && value.length < 6) {
                    return '密码长度不能少于6位';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 30),

              // 登录按钮
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        '登录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 20),

              // 其他选项
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      // 跳转到注册页面
                    },
                    child: const Text('注册账号'),
                  ),
                  TextButton(
                    onPressed: () {
                      // 跳转到忘记密码页面
                    },
                    child: const Text('忘记密码?'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}