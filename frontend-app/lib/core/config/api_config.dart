// lib/config/api_config.dart

class ApiConfig {
  // =========================================================
  // ⚠️ 朋友们请注意：真机调试时，请修改下面的 IP 为你电脑的局域网 IP
  // 提交代码时，最好把这里改回默认的 10.0.2.2 (模拟器通用 IP)
  // =========================================================

  // 你的电脑 IP (Win+R -> cmd -> ipconfig -> IPv4)
  // 如果用模拟器，请填 "10.0.2.2"
  // 如果用真机，请填你电脑的局域网 IP (如 "192.168.1.100")

  //static const String serverIp = "16.176.170.214"; // IP 换成AWS 公网 IP
  static const String serverIp = "10.0.2.2"; // Android 模拟器使用此 IP（默认）
  // static const String serverIp = "172.23.123.48"; // 真机调试时使用此 IP

  // ⚠️ 后端是单体应用，所有服务都在 8080 端口
  // Java 后端端口 (查看 Java 项目终端显示的 http://0.0.0.0:xxxx)
  // calotter 后端默认端口是 8080
  static const String port = "8080";

  /// Recipe 服务端口（后端单体应用，使用 8080）
  static const String recipePort = "8080";

  /// Inventory 服务端口（后端单体应用，使用 8080）
  static const String inventoryPort = "8080";

  /// Homepage 服务端口（后端单体应用，使用 8080）
  static const String homepagePort = "8080";

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
