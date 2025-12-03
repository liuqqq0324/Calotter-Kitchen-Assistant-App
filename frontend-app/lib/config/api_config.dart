// lib/config/api_config.dart

class ApiConfig {
  // =========================================================
  // ⚠️ 朋友们请注意：真机调试时，请修改下面的 IP 为你电脑的局域网 IP
  // 提交代码时，最好把这里改回默认的 10.0.2.2 (模拟器通用 IP)
  // =========================================================

  // 你的电脑 IP (Win+R -> cmd -> ipconfig -> IPv4)
  // 如果用模拟器，请填 "10.0.2.2"

  //static const String serverIp = "10.0.2.2";
  static const String serverIp = "172.23.177.5";

  // C# 后端的端口 (查看 C# 项目终端显示的 http://0.0.0.0:xxxx)
  static const String port = "5108";

  // 这里的 getter 会自动把 IP 和 端口 拼起来
  static String get baseUrl {
    return "http://$serverIp:$port";
  }
}
