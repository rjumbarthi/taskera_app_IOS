---
description: Find the CSS rule(s) styling a prototype element. Useful when widget spec is ambiguous.
argument-hint: <css-selector-or-keyword> (e.g. .sgrp, .qcard, switch, .top-bar)
---

Find every CSS rule in the Kaal prototype that styles `$ARGUMENTS`. Output exact line numbers, full rules, and which screens use the class.

1. **Search shared.css** —
   ```
   grep -nE "$ARGUMENTS" kaal_pkg/shared/shared.css
   ```

2. **Search the prototype** —
   ```
   grep -nE "$ARGUMENTS" kaal_pkg/kaal-prototype.html | head -20
   ```

3. **Read each matched CSS rule.** Print line number, full selector + rule body, and ±5 lines for context.

4. **Cross-reference with components.md.** Check if Kaal's Flutter target is documented. Point to the section. If missing, note it.

5. **Cross-reference with tokens.json.** Check `tokens.json → components_dimensions`.

## Output format

```
## CSS lookup: $ARGUMENTS

### Rules found in shared.css
**Line N** (selector): `.foo`
```css
.foo { ... }
```

### Used in prototype HTML
- p-tasks line N: <div class="foo ...">

### Documented in
- components.md section [X.Y] ✓ / ✗
- tokens.json key [components_dimensions.foo] ✓ / ✗

### Flutter equivalent
[suggested widget implementation if not already in lib/widgets/]
```

Read-only. Don't modify files.
