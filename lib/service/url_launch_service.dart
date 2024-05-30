import 'package:webview_flutter/webview_flutter.dart';

class UrlLaunchService {
  void addClickListenerToATags(WebViewController controller) {
    String script = '''
      function addClickListener() {
        document.querySelectorAll('a').forEach(function(element) {
          element.addEventListener('click', function(event) {
            event.preventDefault(); // 기본 동작 방지
            const url = event.target.href;
            // FlutterChannel로 메시지 보내기
            launchUrl.postMessage(url);
          });
        });
      }
      
      // 초기 설정
      addClickListener();

      // MutationObserver 설정
      const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
          if (mutation.type === 'childList') {
            mutation.addedNodes.forEach((node) => {
              if (node.nodeType === 1 && node.tagName === 'A') {
                node.addEventListener('click', function(event) {
                  event.preventDefault(); // 기본 동작 방지
                  const url = node.href;
                  // FlutterChannel로 메시지 보내기
                  launchUrl.postMessage(url);
                });
              }
              if (node.nodeType === 1 && node.querySelectorAll) {
                node.querySelectorAll('a').forEach((element) => {
                  element.addEventListener('click', function(event) {
                    event.preventDefault(); // 기본 동작 방지
                    const url = element.href;
                    // FlutterChannel로 메시지 보내기
                    launchUrl.postMessage(url);
                  });
                });
              }
            });
          }
        });
      });

      // 페이지 전체를 관찰
      observer.observe(document.body, {
        childList: true,
        subtree: true
      });
    ''';
    controller.runJavaScript(script);
  }
}
