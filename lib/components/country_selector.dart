const Map<String, String> countryFlags = {
  "Anguilla": "🇦🇮",
  "Antigua and Barbuda": "🇦🇬",
  "Bahamas": "🇧🇸",
  "Barbados": "🇧🇧",
  "Belize": "🇧🇿",
  "Bermuda": "🇧🇲",
  "Bonaire": "🇧🇶",
  "British Virgin Islands": "🇻🇬",
  "Cayman Islands": "🇰🇾",
  "Cuba": "🇨🇺",
  "Curacao": "🇨🇼",
  "Dominica": "🇩🇲",
  "Grenada": "🇬🇩",
  "Guadeloupe": "🇬🇵",
  "Jamaica": "🇯🇲",
  "Martinique": "🇲🇶",
  "Montserrat": "🇲🇸",
  "Puerto Rico": "🇵🇷",
  "Saba": "🇧🇶",
  "Saint Barthélemy": "🇧🇱",
  "Saint Kitts and Nevis": "🇰🇳",
  "Saint Lucia": "🇱🇨",
  "Saint Martin": "🇲🇫",
  "Saint Vincent and the Grenadines": "🇻🇨",
  "Eustatius": "🇧🇶",
  "Trinidad and Tobago": "🇹🇹",
  "Turks and Caicos Islands": "🇹🇨",
};

List<String> countryOptions() {
  return countryFlags.keys.toList();
}
