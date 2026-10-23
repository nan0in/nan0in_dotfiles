# English / Japanese offline fortunes

## Contents

| File | Entries | Contents |
| --- | ---: | --- |
| en-computing | 812 | Short historical hacker definitions and Alan J. Perlis programming epigrams |
| en-security | 64 | Historical security-related jargon and selected legacy technical fortunes |
| en-psychology | 12 | Short quotations attributed to Carl Jung by the upstream collection |
| ja-kotowaza | 70 | Japanese proverbs with kana readings and English explanations |

The source snapshot of kotowaza contains 70 entries. Its upstream README's
reference to 600+ proverbs describes the linked website, not this JSON snapshot.

## Provenance and rights

- Jargon File **4.2.2, 20 Aug 2000**: Project Gutenberg ebook 3008,
  <https://www.gutenberg.org/ebooks/3008>. The original text contains its public-domain
  statement, and the saved complete Gutenberg file includes the Gutenberg license.
  Generated records extract a short first definition paragraph and label the version.
  This is historical language/culture, not current security advice. Some entries
  contain dated language, adult jokes or opinions.
- Perlis epigrams and Jung quotations: <https://github.com/JKirchartz/fortunes>,
  pinned commit `8c337f35a3956acf0609f955b0c536920bd46f92`.
  The collection's Unlicense is saved as `sources/fortunes-LICENSE` together with
  its README. Collection licensing does not establish rights to every quotation.
  Jung attributions were inherited, **not individually authenticated**; these are
  historical/popular quotations, not evidence-based mental-health advice.
- Security also samples keyword-matched short entries from the preserved
  `legacy/computers`, `linux`, `debian`, `knghtbrd` and `perl` databases. Each such
  entry retains its source collection name. See `../legacy/COPYING.txt`.
- Japanese: <https://github.com/sepTN/kotowaza>, commit
  `c6435b3e13937fbfb6d464410f68dccf76384264`. MIT license and README preserved as
  `sources/kotowaza-LICENSE` and `sources/kotowaza-README.md`.
  Dataset maintained by Septian Ganendra S. K. / <https://jepang.org/>.

Upstream files remain unchanged in `sources/`. `manifest.json` records source
URLs, SHA-256 hashes and generated counts. Generated files are deduplicated and
control characters are stripped. Psychology is capped at 12 short entries and
receives a 2% category weight in the parent `settings.json`.

## Rebuild

From the dotfiles repository root, run `python3 scripts/update-extra-fortunes.py`
to download the pinned GitHub snapshots and current Gutenberg ebook, or append
`--offline` to rebuild using only the saved sources. Startup never uses networking.

This product includes software developed by the University of California,
Berkeley and its contributors.
