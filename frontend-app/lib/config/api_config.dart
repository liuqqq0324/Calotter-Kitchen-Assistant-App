// lib/config/api_config.dart

class ApiConfig {
  // =========================================================
  // ⚠️ 朋友们请注意：真机调试时，请修改下面的 IP 为你电脑的局域网 IP
  // 提交代码时，最好把这里改回默认的 10.0.2.2 (模拟器通用 IP)
  // =========================================================

  // 你的电脑 IP (Win+R -> cmd -> ipconfig -> IPv4)
  // 如果用模拟器，请填 "10.0.2.2"
  // 如果用真机，请填你电脑的局域网 IP (如 "192.168.1.100")

  static const String serverIp = "10.0.2.2"; // Android 模拟器使用此 IP
  // static const String serverIp = "172.24.12.77"; // 真机调试时使用此 IP

  // C# 后端的端口 (查看 C# 项目终端显示的 http://0.0.0.0:xxxx)
  // 一般默认是 5108
  // Java后端的端口 (查看 Java 项目终端显示的 http://0.0.0.0：xxxx)
  // calotter-user 服务端口是 10000
  static const String port = "10000";

  /// Recipe 服务端口（calotter-recipe 默认 9000）
  static const String recipePort = "9000";

  /// Inventory 服务端口（calotter-inventory 默认 8000）
  static const String inventoryPort = "8000";

  /// Homepage 服务端口（calotter-homepage 默认 10001）
  static const String homepagePort = "10001";

  // 这里的 getter 会自动把 IP 和 端口 拼起来
  static String get baseUrl {
    return "http://$serverIp:$port";
  }

  static String get recipeBaseUrl {
    return "http://$serverIp:$recipePort";
  }

  static String get inventoryBaseUrl {
    return "http://$serverIp:$inventoryPort";
  }

  static String get homepageBaseUrl {
    return "http://$serverIp:$homepagePort";
  }
}
