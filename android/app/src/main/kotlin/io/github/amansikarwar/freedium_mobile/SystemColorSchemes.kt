package io.github.amansikarwar.freedium_mobile

import android.content.Context
import android.graphics.Color
import android.os.Build

internal fun systemColorSchemes(context: Context): Map<String, Map<String, Int>>? {
    // Android exposes the complete role set, including inverse colors, from API 37.
    if (Build.VERSION.SDK_INT < 37) return null

    val roles = listOf(
        "primary", "on_primary", "primary_container", "on_primary_container",
        "primary_fixed", "primary_fixed_dim", "on_primary_fixed", "on_primary_fixed_variant",
        "secondary", "on_secondary", "secondary_container", "on_secondary_container",
        "secondary_fixed", "secondary_fixed_dim", "on_secondary_fixed", "on_secondary_fixed_variant",
        "tertiary", "on_tertiary", "tertiary_container", "on_tertiary_container",
        "tertiary_fixed", "tertiary_fixed_dim", "on_tertiary_fixed", "on_tertiary_fixed_variant",
        "error", "on_error", "error_container", "on_error_container",
        "surface", "on_surface", "surface_dim", "surface_bright",
        "surface_container_lowest", "surface_container_low", "surface_container",
        "surface_container_high", "surface_container_highest", "on_surface_variant",
        "outline", "outline_variant", "inverse_surface", "inverse_on_surface", "inverse_primary",
    )
    val schemes = mutableMapOf<String, Map<String, Int>>()
    for (mode in listOf("light", "dark")) {
        val colors = mutableMapOf<String, Int>()
        for (role in roles) {
            val modeResource = context.resources.getIdentifier("system_${role}_$mode", "color", "android")
            val resourceId = if (modeResource != 0) modeResource else
                context.resources.getIdentifier("system_$role", "color", "android")
            if (resourceId == 0) return null
            colors[role] = context.getColor(resourceId)
        }
        colors["shadow"] = Color.BLACK
        colors["scrim"] = Color.BLACK
        colors["surface_tint"] = colors.getValue("primary")
        schemes[mode] = colors
    }
    return schemes
}
