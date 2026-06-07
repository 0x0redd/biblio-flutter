#!/usr/bin/env python3
"""Scrape all books from http://books.toscrape.com/ and their detail pages."""

from __future__ import annotations

import argparse
import csv
import json
import re
import sys
import time
from pathlib import Path
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

BASE_URL = "https://books.toscrape.com/"
CATALOG_URL = urljoin(BASE_URL, "catalogue/page-1.html")
# Root index lists the same catalogue; page-1 is the stable entry point.
INDEX_URL = urljoin(BASE_URL, "index.html")

RATING_MAP = {
    "One": 1,
    "Two": 2,
    "Three": 3,
    "Four": 4,
    "Five": 5,
}

OUTPUT_DIR = Path(__file__).resolve().parent


def get_soup(session: requests.Session, url: str) -> BeautifulSoup:
    response = session.get(url, timeout=30)
    response.raise_for_status()
    return BeautifulSoup(response.text, "html.parser")


def parse_price(text: str) -> float | None:
    match = re.search(r"[\d.]+", text.replace(",", ""))
    return float(match.group()) if match else None


def star_rating_from_class(classes: list[str]) -> int | None:
    for name in classes:
        if name in RATING_MAP:
            return RATING_MAP[name]
    return None


def collect_book_urls(soup: BeautifulSoup, page_url: str) -> list[str]:
    urls: list[str] = []
    for article in soup.select("article.product_pod"):
        link = article.select_one("h3 a")
        if link and link.get("href"):
            urls.append(urljoin(page_url, link["href"]))
    return urls


def next_catalog_page(soup: BeautifulSoup, page_url: str) -> str | None:
    next_link = soup.select_one("li.next a")
    if next_link and next_link.get("href"):
        return urljoin(page_url, next_link["href"])
    return None


def iter_catalog_pages(
    session: requests.Session, start_url: str = CATALOG_URL
):
    url: str | None = start_url
    while url:
        soup = get_soup(session, url)
        yield url, soup
        url = next_catalog_page(soup, url)


def parse_product_table(soup: BeautifulSoup) -> dict[str, str]:
    table: dict[str, str] = {}
    for row in soup.select("table.table-striped tr"):
        header = row.select_one("th")
        cell = row.select_one("td")
        if header and cell:
            table[header.get_text(strip=True)] = cell.get_text(strip=True)
    return table


def parse_book_page(soup: BeautifulSoup, book_url: str) -> dict:
    title_el = soup.select_one("div.product_main h1")
    title = title_el.get_text(strip=True) if title_el else ""

    price_el = soup.select_one("p.price_color")
    price_text = price_el.get_text(strip=True) if price_el else ""

    availability_el = soup.select_one("p.instock.availability")
    availability = " ".join(availability_el.stripped_strings) if availability_el else ""

    stock_count: int | None = None
    stock_match = re.search(r"\((\d+) available\)", availability)
    if stock_match:
        stock_count = int(stock_match.group(1))

    rating_el = soup.select_one("p.star-rating")
    rating: int | None = None
    if rating_el and rating_el.get("class"):
        rating = star_rating_from_class(rating_el["class"])

    description_el = soup.select_one("#product_description + p")
    description = description_el.get_text(strip=True) if description_el else ""

    image_el = soup.select_one("#product_gallery img")
    image_url = ""
    if image_el and image_el.get("src"):
        image_url = urljoin(book_url, image_el["src"])

    breadcrumbs = [
        a.get_text(strip=True)
        for a in soup.select("ul.breadcrumb a")
    ]
    category = breadcrumbs[-1] if len(breadcrumbs) >= 2 else ""
    # breadcrumb: Home > Books > Poetry > Title
    subcategory = breadcrumbs[-2] if len(breadcrumbs) >= 3 else ""

    product_info = parse_product_table(soup)

    upc = product_info.get("UPC", "")
    product_type = product_info.get("Product Type", "")
    price_excl_tax = parse_price(product_info.get("Price (excl. tax)", ""))
    price_incl_tax = parse_price(product_info.get("Price (incl. tax)", ""))
    tax = parse_price(product_info.get("Tax", ""))
    num_reviews = product_info.get("Number of reviews", "")

    book_id_match = re.search(r"_(\d+)/", book_url)
    book_id = int(book_id_match.group(1)) if book_id_match else None

    in_stock = availability.lower().startswith("in stock")

    return {
        "id": book_id,
        "url": book_url,
        "title": title,
        "price": parse_price(price_text),
        "price_incl_tax": price_incl_tax,
        "price_excl_tax": price_excl_tax,
        "tax": tax,
        "rating": rating,
        "availability": availability,
        "in_stock": in_stock,
        "stock_count": stock_count,
        "description": description,
        "category": category,
        "subcategory": subcategory,
        "breadcrumbs": breadcrumbs,
        "image_url": image_url,
        "upc": upc,
        "product_type": product_type,
        "number_of_reviews": int(num_reviews) if num_reviews.isdigit() else None,
    }


def scrape_all(
    *,
    limit: int | None = None,
    delay: float = 0.0,
    verbose: bool = True,
) -> list[dict]:
    session = requests.Session()
    session.headers["User-Agent"] = "biblio-flutter-scraper/1.0"

    book_urls: list[str] = []
    for page_num, (page_url, soup) in enumerate(iter_catalog_pages(session), start=1):
        urls = collect_book_urls(soup, page_url)
        book_urls.extend(urls)
        if verbose:
            print(f"Catalog page {page_num}: {len(urls)} books ({page_url})", file=sys.stderr)
        if limit is not None and len(book_urls) >= limit:
            book_urls = book_urls[:limit]
            break

    if verbose:
        print(f"Found {len(book_urls)} book URLs", file=sys.stderr)

    books: list[dict] = []
    for index, book_url in enumerate(book_urls, start=1):
        if delay > 0:
            time.sleep(delay)
        soup = get_soup(session, book_url)
        book = parse_book_page(soup, book_url)
        books.append(book)
        if verbose:
            print(f"[{index}/{len(book_urls)}] {book['title']}", file=sys.stderr)

    return books


def save_json(books: list[dict], path: Path) -> None:
    path.write_text(json.dumps(books, indent=2, ensure_ascii=False), encoding="utf-8")


def save_csv(books: list[dict], path: Path) -> None:
    if not books:
        path.write_text("", encoding="utf-8")
        return

    fieldnames = [
        "id",
        "title",
        "price",
        "price_excl_tax",
        "price_incl_tax",
        "tax",
        "rating",
        "availability",
        "in_stock",
        "stock_count",
        "category",
        "subcategory",
        "upc",
        "product_type",
        "number_of_reviews",
        "url",
        "image_url",
        "description",
    ]
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        writer.writeheader()
        writer.writerows(books)


def main() -> None:
    parser = argparse.ArgumentParser(description="Scrape books.toscrape.com")
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Max number of books (for testing)",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.0,
        help="Seconds to wait between detail page requests",
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=OUTPUT_DIR,
        help="Directory for books.json and books.csv",
    )
    parser.add_argument(
        "--import-json",
        type=Path,
        default=None,
        metavar="PATH",
        help="Load books from JSON instead of scraping",
    )
    parser.add_argument("-q", "--quiet", action="store_true")
    args = parser.parse_args()

    if args.import_json:
        books = json.loads(args.import_json.read_text(encoding="utf-8"))
        if not args.quiet:
            print(f"Loaded {len(books)} books from {args.import_json}", file=sys.stderr)
    else:
        books = scrape_all(
            limit=args.limit,
            delay=args.delay,
            verbose=not args.quiet,
        )

    args.output_dir.mkdir(parents=True, exist_ok=True)
    json_path = args.output_dir / "books.json"
    csv_path = args.output_dir / "books.csv"
    save_json(books, json_path)
    save_csv(books, csv_path)
    if not args.quiet:
        print(f"Saved {len(books)} books to {json_path} and {csv_path}")
        print("Run 'cd ../backend && npm run seed' to import CSV into MongoDB.", file=sys.stderr)


if __name__ == "__main__":
    main()
