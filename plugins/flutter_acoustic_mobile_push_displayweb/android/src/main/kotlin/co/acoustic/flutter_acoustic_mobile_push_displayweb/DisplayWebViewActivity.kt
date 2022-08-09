package co.acoustic.flutter_acoustic_mobile_push_displayweb;

import android.R
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity

/**
 * Created by minho choi on 11/18/21.
 */
class DisplayWebViewActivity: AppCompatActivity() {

    private var webView: WebView? = null
    private var actionBackId = 0
    private var actionForwardId = 0
    private var actionDoneId = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        actionBackId = resources.getIdentifier("action_back", "id", packageName)
        actionForwardId = resources.getIdentifier("action_forward", "id", packageName)
        actionDoneId = resources.getIdentifier("action_done", "id", packageName)
        super.onCreate(savedInstanceState)
        setTheme(R.style.Theme_Holo)
        val layoutId = resources.getIdentifier("activity_action_webview", "layout", packageName)
        setContentView(layoutId)
        title = "" // clear the title
        val url = intent.getStringExtra("url")
        val webViewId = resources.getIdentifier("webView", "id", packageName)
        webView = findViewById<View>(webViewId) as WebView



        webView!!.webViewClient = WebViewClient()
        if (url != null) {
            webView!!.loadUrl(url)
        }
    }

    /**
     * This method inflates the menu
     * @param menu The menu
     * @return
     */
    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        val menuId = resources.getIdentifier("menu_action_webview", "menu", packageName)
        menuInflater.inflate(menuId, menu)
        return true
    }

    /**
     * This method handles a menu selection (back, forward or done).
     * @param item The selected menu item (back, forward or done).
     * @return
     */
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            actionBackId -> {
                webView!!.goBack()
                true
            }
            actionForwardId -> {
                webView!!.goForward()
                true
            }
            actionDoneId -> {
                finish()
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
}