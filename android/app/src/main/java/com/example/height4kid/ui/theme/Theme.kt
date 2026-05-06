package com.example.height4kid.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material.MaterialTheme
import androidx.compose.material.darkColors
import androidx.compose.material.lightColors
import androidx.compose.runtime.Composable

private val DarkColorPalette = darkColors(
    primary = PeachPink,
    primaryVariant = SoftCoral,
    secondary = WarmApricot
)

private val LightColorPalette = lightColors(
    primary = PeachPink,
    primaryVariant = SoftCoral,
    secondary = WarmApricot,
    background = Cream,
    surface = White,
    onPrimary = Black,
    onSecondary = Black,
    onBackground = Black,
    onSurface = Black
)

@Composable
fun Height4KidTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colors = if (darkTheme) {
        DarkColorPalette
    } else {
        LightColorPalette
    }

    MaterialTheme(
        colors = colors,
        typography = Typography,
        shapes = Shapes,
        content = content
    )
}