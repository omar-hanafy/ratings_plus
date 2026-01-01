# The Ratings Plus Documentation Standard

## Our Philosophy: "Describe the Behavior, Not Just the Data"

At *Ratings Plus*, we believe that documentation is not just a label on a variable; it is the manual for the machinery. A developer reading our docs should not only know *what* a parameter is, but *how* it changes the universe of the application.

**The Core Mantra:**
> "Don't tell me this is a button. Tell me what happens when I press it, what happens if I disable it, and why I should use it instead of the other button."

---

## 1. The Three Layers of a Great Doc Comment

Every public API (Class, Method, Property) should aim to satisfy three layers of understanding:

### Layer 1: The Definition (The "What")
*Basic. Required. Usually the first sentence.*
*   **Bad:** `/// The duration.`
*   **Good:** `/// The duration of the fade animation when the rating value changes.`

### Layer 2: The Context (The "When")
*Guidance. Helps the developer choose.*
*   **Bad:** `/// Sets the gesture mode.`
*   **Good:** `/// Use [RatingGestureMode.tap] when this widget is inside a scrollable list to prevent accidental drag interactions.`

### Layer 3: The Interaction (The "How")
*The "Flutter Standard." Describes side effects, constraints, and relationships.*
*   **Bad:** `/// The color of the glow.`
*   **Good:** `/// If null, defaults to [RatingBarThemeData.glowColor]. If that is also null, falls back to [ColorScheme.primary] from the current [Theme].`

---

## 2. Writing Guidelines

### A. Connect the Dots (`[...]`)
Never force a developer to search for a related class. Use square brackets `[Reference]` liberally to create hyperlinks in the IDE.
*   **Rule:** If a property relies on another class, links to a theme, or affects a different widget, link it.
*   **Example:** `/// See also: [RatingBarIndicator] for a read-only variant.`

### B. Define Constraints & Defaults
Ambiguity is the enemy. Always answer:
1.  **Nullability:** What happens if this is null? (e.g., "Defaults to `Colors.amber`").
2.  **Range:** What are the valid values? (e.g., "Must be greater than 0").
3.  **State:** Does changing this trigger a rebuild?

### C. The "Why" over The "What"
For complex logic, explain the motivation.
*   **Instead of:** `/// Updates the _internalValue.`
*   **Say:** `/// Updates the internal state to reflect the user's drag, but does not commit the value via [onChanged] until the gesture ends.`

---

## 3. Practical Examples

### Example 1: A Property
**The Goal:** Documenting `itemSize`.

*   ❌ **The "Lazy" Way:**
    ```dart
    /// The size of the item.
    final double? itemSize;
    ```

*   ✅ **The "Ratings Plus" Way:**
    ```dart
    /// The size (width and height) of each rating item.
    ///
    /// This enforces a square constraint on the widgets returned by [itemBuilder].
    ///
    /// If null, this defaults to [RatingBarThemeData.itemSize] (usually 40.0).
    /// Changing this value will trigger a layout rebuild.
    final double? itemSize;
    ```

### Example 2: A Class
**The Goal:** Documenting `RatingBar`.

*   ❌ **The "Lazy" Way:**
    ```dart
    /// A rating bar widget.
    class RatingBar extends StatefulWidget ...
    ```

*   ✅ **The "Ratings Plus" Way:**
    ```dart
    /// A highly customizable, interactive rating bar widget.
    ///
    /// [RatingBar] allows users to select a rating value using touch, mouse, or
    /// keyboard interactions.
    ///
    /// ### Interaction Models
    /// * **Controlled:** Provide [value] and handle [onChanged].
    /// * **Uncontrolled:** Provide [initialValue] and let the widget manage state.
    ///
    /// Designed to integrate with Flutter's [Form] system via [RatingBar.form].
    class RatingBar extends StatefulWidget ...
    ```

---

## 4. Private Code Documentation

We apply the same rigor to private (`_`) members when the logic is complex. Future maintainers (including you in 6 months) need to know the *story* of the implementation.

*   **Don't comment:** `// Increment i.`
*   **Do comment:** `// We clamp the value here to ensure the visual fill doesn't overflow the container when the user drags quickly outside the bounds.`

---

## 5. The Checklist

Before merging a PR, ask:
1.  [ ] Does the first sentence summarize the "What"?
2.  [ ] Did I explain what happens if inputs are null?
3.  [ ] Did I mention interactions with other widgets or Themes?
4.  [ ] Did I use `[SquareBrackets]` for references?
5.  [ ] Is there an example for complex usage?

---

*This document serves as the source of truth for all documentation contributions to Ratings Plus.*
