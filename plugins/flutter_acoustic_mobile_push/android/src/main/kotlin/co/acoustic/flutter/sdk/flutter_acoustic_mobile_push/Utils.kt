package co.acoustic.flutter.sdk.flutter_acoustic_mobile_push

import android.os.Bundle
import co.acoustic.mobile.push.sdk.api.attribute.*
import co.acoustic.mobile.push.sdk.util.Logger
import org.json.JSONObject
import org.json.JSONArray
import org.json.JSONException
import java.lang.Exception
import java.lang.IllegalArgumentException
import java.text.SimpleDateFormat


/**
 * Created by minho choi on 11/10/21.
 */

fun convertJsonObject(jsonObject: JSONObject): HashMap<String, Any?> {
    var map: HashMap<String, Any?> = HashMap()

    var jsonIterator = jsonObject.keys()
    while (jsonIterator.hasNext()) {
        val key = jsonIterator.next()
        val value = jsonObject[key]
        if (value == null || value === JSONObject.NULL) {
            map[key] = null
        } else if (value is Boolean) {
            map[key] = value as Boolean
        } else if (value is Int) {
            map[key] = value as Int
        } else if (value is Long) {
            map[key] = value.toDouble()
        } else if (value is Double) {
            map[key] = value as Double
        } else if (value is String) {
            map[key] = value as String
        } else if (value is JSONObject) {
            map[key] = convertJsonObject((value as JSONObject)!!)
        } else if (value is JSONArray) {
            map[key] = convertJsonArray(value as JSONArray)
        } else {
            throw IllegalArgumentException("Unsupported type: " + value.javaClass)
        }
    }

    return map
}

fun convertFromJsontoHashMap(jsonObject: JSONObject): HashMap<String, String> {
    var map: HashMap<String, String> = HashMap()
    var jsonIterator = jsonObject.keys()
    while (jsonIterator.hasNext()) {
        val key = jsonIterator.next()
        val value = jsonObject[key]
        if (value == null || value === JSONObject.NULL) {
            map[key] = "<NULL>"
        } else if (value is Boolean) {
            map[key] = value.toString()
        } else if (value is Int) {
            map[key] = value.toString()
        } else if (value is Long) {
            map[key] = value.toDouble().toString()
        } else if (value is Double) {
            map[key] = value.toString()
        } else if (value is String) {
            map[key] = value
        } else if (value is JSONObject) {
            map[key] = convertJsonObject((value as JSONObject)!!).toString()
        } else if (value is JSONArray) {
            map[key] = convertJsonArray(value as JSONArray).toString()
        } else {
            throw IllegalArgumentException("Unsupported type: " + value.javaClass)
        }
    }

    return map
}

fun convertJsonArray(jsonArray: JSONArray): ArrayList<Any?> {
    val array: ArrayList<Any?> = ArrayList()
    for (i in 0 until jsonArray.length()) {
        var map: HashMap<String, Any?> = HashMap()
        val value: Any = jsonArray.get(i)
        if (value == null || value === JSONObject.NULL) {
            array.add(null)
        } else if (value is Boolean) {
            array.add(value as Boolean)
        } else if (value is Int) {
            array.add(value as Int)
        } else if (value is Long) {
            array.add(value.toDouble())
        } else if (value is Double) {
            array.add(value as Double)
        } else if (value is String) {
            array.add(value as String)
        } else if (value is JSONObject) {
            array.add(convertJsonObject((value as JSONObject)!!))
        } else if (value is JSONArray) {
            array.add(convertJsonArray((value as JSONArray)!!))
        } else {
            throw IllegalArgumentException("Unsupported type: " + value.javaClass)
        }
    }
    return array
}

@Throws(JSONException::class)
fun convertJsonObjectToBundle(jsonObject: JSONObject): Bundle {
    val bundle = Bundle()
    val jsonIterator = jsonObject.keys()
    while (jsonIterator.hasNext()) {
        val key = jsonIterator.next()
        when (val value = jsonObject[key]) {
            is Boolean -> {
                bundle.putShort(key, (if (value == true) 1 else 0).toShort())
            }
            is Int -> {
                bundle.putFloat(key, value.toFloat())
            }
            is Long -> {
                bundle.putFloat(key, value.toFloat())
            }
            is Double -> {
                bundle.putFloat(key, value.toFloat())
            }
            is String -> {
                bundle.putString(key, value)
            }
            is JSONObject -> {
                bundle.putBundle(key, convertJsonObjectToBundle(value))
            }
            is JSONArray -> {
                val array = ArrayList<String>()
                for (i in 0 until value.length()) {
                    val arrayValue = value[i]
                    array.add(arrayValue.toString())
                }
                bundle.putStringArrayList(key, array)
            }
        }
    }
    return bundle
}

fun convertJsonToAttribute(jsonObject: JSONObject): List<Attribute> {
    val attributes: MutableList<Attribute> = ArrayList()
    val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")

    val type = jsonObject.getString("type")
    val value = jsonObject.getString("value")
    val key = jsonObject.getString("key")

    if (type.isNullOrEmpty().not()) {
        when (type) {
            "date" -> {
                attributes.add(DateAttribute(key, dateFormat.parse(value)))
            }
            "string" -> {
                attributes.add(StringAttribute(key, value))
            }
            "boolean" -> {
                if (value == "true") {
                    attributes.add(BooleanAttribute(key, true))
                } else {
                    attributes.add(BooleanAttribute(key, false))
                }
            }
            "number" -> {
                attributes.add(NumberAttribute(key, value.toDouble()))
            }
            else -> {
                Logger.e(
                    "TAG",
                    "Ignoring invalid value type NULL sent as value for attribute key $key for event."
                )
            }
        }
    }

    return attributes;
}

fun convertReadableMapToAttributes(attributesMap: JSONObject): List<Attribute> {
    val attributes: MutableList<Attribute> = ArrayList()
    val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'")
    val iterator = attributesMap.keys()


    while (iterator.hasNext()) {
        val key: String = iterator.next()
        when (attributesMap.get(key)) {
            null -> {
                Logger.e(
                    "TAG",
                    "Ignoring invalid value type NULL sent as value for attribute key $key for event."
                )
            }
            is Boolean -> {
                attributes.add(BooleanAttribute(key, attributesMap.getBoolean(key)))
            }
            is Double -> {
                attributes.add(NumberAttribute(key, attributesMap.getDouble(key)))
            }
            is String -> {
                val stringValue: String = attributesMap.getString(key)
                try {
                    attributes.add(DateAttribute(key, dateFormat.parse(stringValue)))
                } catch (ex: Exception) {
                    attributes.add(StringAttribute(key, stringValue))
                }
            }
            else -> {
                Logger.e(
                    "TAG",
                    "Ignoring invalid value type NULL sent as value for attribute key $key for event."
                )
            }
        }
    }
    return attributes
}
