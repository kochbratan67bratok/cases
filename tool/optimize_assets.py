from pathlib import Path
import sys
from PIL import Image, ImageOps

LIMITS = {'stickers': (256, 82), 'graffiti': (256, 82), 'patches': (256, 82), 'pins': (256, 82), 'charms': (256, 82), 'music_kits': (256, 82), 'tournament_logos': (256, 82), 'skins': (512, 85), 'containers': (512, 85), 'agents': (512, 85)}

def main():
    if len(sys.argv) != 2:
        raise SystemExit('usage: optimize_assets.py <assets-directory>')
    root = Path(sys.argv[1])
    if not root.is_dir():
        raise SystemExit(f'assets directory not found: {root}')
    files = [p for p in root.rglob('*.webp') if p.parent.name in LIMITS]
    before = sum(p.stat().st_size for p in files)
    saved = changed = skipped = 0
    for path in files:
        old_size = path.stat().st_size
        edge, quality = LIMITS[path.parent.name]
        temp = path.with_name(path.name + '.optimized-tmp')
        try:
            with Image.open(path) as source:
                if getattr(source, 'is_animated', False):
                    skipped += 1
                    continue
                if source.width <= edge and source.height <= edge and old_size <= 40 * 1024:
                    skipped += 1
                    continue
                image = ImageOps.exif_transpose(source)
                image.load()
                image.thumbnail((edge, edge), Image.Resampling.LANCZOS)
                alpha = 'A' in image.getbands() or 'transparency' in image.info
                image.convert('RGBA' if alpha else 'RGB').save(temp, format='WEBP', quality=quality, method=4, alpha_quality=100)
            new_size = temp.stat().st_size
            if new_size < old_size:
                temp.replace(path)
                saved += old_size - new_size
                changed += 1
            else:
                temp.unlink(missing_ok=True)
        except Exception as error:
            temp.unlink(missing_ok=True)
            print(f'warning: kept {path}: {error}', file=sys.stderr)
            skipped += 1
    pct = 100 * saved / before if before else 0
    print(f'WebP assets: {changed} files optimized; {before:,} -> {before-saved:,} bytes; saved {saved:,} bytes ({pct:.1f}%); skipped {skipped}.')
    print('No assets were deleted and every asset path remains unchanged.')

if __name__ == '__main__':
    main()
