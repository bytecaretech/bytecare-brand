# bytecare-brand

The byteCare brand (colours, typography and logo) as a [Quarto][quarto]
brand extension. The brand is defined in the [brand.yml][brand-yml] format
in [`_extensions/bytecare/brand.yml`](_extensions/bytecare/brand.yml).

The brand holds only what applies to every medium. Site-specific or
slide-specific choices, such as a white page background, belong in the
consuming project.

## Install

In the root of a Quarto project (Quarto 1.8 or later):

```bash
quarto add bytecaretech/bytecare-brand
```

This installs the extension into `_extensions/bytecaretech/bytecare/`.
Quarto puts extensions installed from GitHub under the owner's name. Check
that directory into version control. Every document in the project, including
HTML pages and reveal.js presentations, then uses the brand. The
extension's brand takes precedence over a `_brand.yml` in the project.

To pin a release, add its tag:

```bash
quarto add bytecaretech/bytecare-brand@v1.0.0
```

## Update

```bash
quarto update bytecaretech/bytecare-brand
```

## Fonts

Poppins (headings), Roboto (body text) and JetBrains Mono (code) load from
[Bunny Fonts][bunny]. This means:

- Each visitor's browser requests the fonts from `fonts.bunny.net`, which
  sends their IP address to that third party. Mention this in the privacy
  policy of any website that uses the brand.
- Without an internet connection, the browser uses fonts it has cached from
  an earlier visit, or otherwise falls back to system fonts. To be safe,
  open a presentation once while online before presenting offline, in the
  same browser.

Bundling the fonts with the extension doesn't work yet: Quarto 1.10 doesn't
copy brand font files into reveal.js output, so presentations would always
fall back to system fonts.

## Preview and test

[`example.qmd`](example.qmd) is a small document that uses the brand. Render
it as an HTML page (`example.html`) and a reveal.js presentation
(`example-slides.html`):

```bash
quarto render example.qmd
```

To preview with live reload while changing the brand:

```bash
quarto preview example.qmd
```

[`tests/acceptance.sh`](tests/acceptance.sh) renders the example and checks
that both outputs carry the brand's fonts and logo:

```bash
tests/acceptance.sh
```

## Release

After merging a change, tag a release so projects can pin it:

```bash
git tag v1.0.0 && git push origin v1.0.0
```

Keep the tag in step with `version` in
[`_extensions/bytecare/_extension.yml`](_extensions/bytecare/_extension.yml).

[quarto]: https://quarto.org
[brand-yml]: https://posit-dev.github.io/brand-yml/
[bunny]: https://fonts.bunny.net
