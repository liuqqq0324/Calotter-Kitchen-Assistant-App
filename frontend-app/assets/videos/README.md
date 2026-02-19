# 视频资源说明 / Video Assets Guide

## 如何添加视频 / How to Add Videos

### 方法一：使用本地视频文件（推荐）

1. 将视频文件（MP4格式）放入此目录
2. 文件名建议：`background.mp4` 或 `landing_video.mp4`
3. 在代码中使用：
   ```dart
   VideoBackground(
     videoPath: 'assets/videos/background.mp4',
     child: YourWidget(),
   )
   ```

### 方法二：使用网络视频URL

1. 找到合适的视频URL（确保可以公开访问）
2. 在代码中使用：
   ```dart
   VideoBackground(
     videoUrl: 'https://your-video-url.com/video.mp4',
     child: YourWidget(),
   )
   ```

## 视频要求 / Video Requirements

- **格式 / Format**: MP4 (H.264编码)
- **时长 / Duration**: 10-30秒（会循环播放）
- **分辨率 / Resolution**: 720p或1080p
- **大小 / Size**: 建议小于10MB（本地文件）
- **主题 / Theme**: 美味健康、烹饪相关

## 免费视频资源推荐 / Free Video Resources

### 1. Pexels Videos
- 网址：https://www.pexels.com/videos/
- 搜索关键词：cooking, food, healthy, kitchen
- 免费商用，无需署名

### 2. Pixabay Videos
- 网址：https://pixabay.com/videos/
- 搜索关键词：cooking, food preparation, healthy meal
- 免费商用

### 3. Coverr
- 网址：https://coverr.co/
- 有专门的Food分类
- 免费商用

## 当前使用的占位视频

目前代码中使用的是示例网络视频URL，需要替换为实际视频。

## 注意事项

- 确保视频文件已添加到 `pubspec.yaml` 的 `assets` 部分
- 网络视频需要确保URL可访问且稳定
- 建议使用本地视频以获得更好的性能和用户体验

