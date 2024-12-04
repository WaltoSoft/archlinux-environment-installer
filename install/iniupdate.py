#!/usr/bin/env python3
import configparser
import io
import re
import sys

class CommentConfigParser(configparser.ConfigParser):
    """Comment preserving ConfigParser.
    Limitation: No support for indenting section headers,
    comments and keys. They should have no leading whitespace.
    """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Backup _comment_prefixes
        self._comment_prefixes_backup = self._comment_prefixes
        # Unset _comment_prefixes so comments won't be skipped
        self._comment_prefixes = ()
        # Starting point for the comment IDs
        self._comment_id = 0
        # Default delimiter to use
        delimiter = self._delimiters[0]
        # Template to store comments as key value pair
        self._comment_template = "#{0} " + delimiter + " {1}"
        # Regex to match the comment prefix
        self._comment_regex = re.compile(r"^#\d+\s*" + re.escape(delimiter) + r"[^\S\n]*")
        # Regex to match cosmetic newlines (skips newlines in multiline values):
        # consecutive whitespace from start of line followed by a line not starting with whitespace
        self._cosmetic_newlines_regex = re.compile(r"^(\s+)(?=^\S)", re.MULTILINE)
        # List to store comments above the first section
        self._top_comments = []

    def _find_cosmetic_newlines(self, text):
        # Indices of the lines containing cosmetic newlines
        cosmetic_newline_indices = set()
        for match in re.finditer(self._cosmetic_newlines_regex, text):
            start_index = text.count("\n", 0, match.start())
            end_index = start_index + text.count("\n", match.start(), match.end())
            cosmetic_newline_indices.update(range(start_index, end_index))

        return cosmetic_newline_indices

    def _read(self, fp, fpname):
        lines = fp.readlines()
        cosmetic_newline_indices = self._find_cosmetic_newlines("".join(lines))

        above_first_section = True
        # Preprocess config file to preserve comments
        for i, line in enumerate(lines):
            if line.startswith("["):
                above_first_section = False
            elif above_first_section:
                # Remove this line for now
                lines[i] = ""
                self._top_comments.append(line)
            elif i in cosmetic_newline_indices or line.startswith(
                self._comment_prefixes_backup
            ):
                # Store cosmetic newline or comment with unique key
                lines[i] = self._comment_template.format(self._comment_id, line)
                self._comment_id += 1

        # Feed the preprocessed file to the original _read method
        return super()._read(io.StringIO("".join(lines)), fpname)

    def write(self, fp, space_around_delimiters=True):
        # Write the config to an in-memory file
        with io.StringIO() as sfile:
            super().write(sfile, space_around_delimiters)
            # Start from the beginning of sfile
            sfile.seek(0)
            lines = sfile.readlines()

        cosmetic_newline_indices = self._find_cosmetic_newlines("".join(lines))

        for i, line in enumerate(lines):
            if i in cosmetic_newline_indices:
                # Remove newlines added below each section by .write()
                lines[i] = ""
                continue
            # Remove the comment prefix (if regex matches)
            lines[i] = self._comment_regex.sub("", line, 1)

        fp.write("".join(self._top_comments + lines).rstrip())

    def clear(self):
        # Also clear the _top_comments
        self._top_comments = []
        super().clear()


fileName = sys.argv[1];
section = sys.argv[2];
key=sys.argv[3]
value=sys.argv[4]

config = CommentConfigParser(
  interpolation=None,
  allow_no_value=True,
  comment_prefixes=("#"),
)
config.optionxform = str
config.read(fileName)
updateSection = config[section]
updateSection[key]=value

with open(fileName, 'w') as configfile:
  config.write(configfile, space_around_delimiters=False)

