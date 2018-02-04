use NativeCall;
use Git::Error;
use Git::Oid;
use Git::FileMode;
use Git::Submodule;
use Git::Strarray;
use Git::Buffer;
use Git::Signature;
use Git::Patch;

enum Git::Diff::Option (
    GIT_DIFF_NORMAL                          => 0,
    GIT_DIFF_REVERSE                         => 1 +< 0,
    GIT_DIFF_INCLUDE_IGNORED                 => 1 +< 1,
    GIT_DIFF_RECURSE_IGNORED_DIRS            => 1 +< 2,
    GIT_DIFF_INCLUDE_UNTRACKED               => 1 +< 3,
    GIT_DIFF_RECURSE_UNTRACKED_DIRS          => 1 +< 4,
    GIT_DIFF_INCLUDE_UNMODIFIED              => 1 +< 5,
    GIT_DIFF_INCLUDE_TYPECHANGE              => 1 +< 6,
    GIT_DIFF_INCLUDE_TYPECHANGE_TREES        => 1 +< 7,
    GIT_DIFF_IGNORE_FILEMODE                 => 1 +< 8,
    GIT_DIFF_IGNORE_SUBMODULES               => 1 +< 9,
    GIT_DIFF_IGNORE_CASE                     => 1 +< 10,
    GIT_DIFF_INCLUDE_CASECHANGE              => 1 +< 11,
    GIT_DIFF_DISABLE_PATHSPEC_MATCH          => 1 +< 12,
    GIT_DIFF_SKIP_BINARY_CHECK               => 1 +< 13,
    GIT_DIFF_ENABLE_FAST_UNTRACKED_DIRS      => 1 +< 14,
    GIT_DIFF_UPDATE_INDEX                    => 1 +< 15,
    GIT_DIFF_INCLUDE_UNREADABLE              => 1 +< 16,
    GIT_DIFF_INCLUDE_UNREADABLE_AS_UNTRACKED => 1 +< 17,
    GIT_DIFF_FORCE_TEXT                      => 1 +< 20,
    GIT_DIFF_FORCE_BINARY                    => 1 +< 21,
    GIT_DIFF_IGNORE_WHITESPACE               => 1 +< 22,
    GIT_DIFF_IGNORE_WHITESPACE_CHANGE        => 1 +< 23,
    GIT_DIFF_IGNORE_WHITESPACE_EOL           => 1 +< 24,
    GIT_DIFF_SHOW_UNTRACKED_CONTENT          => 1 +< 25,
    GIT_DIFF_SHOW_UNMODIFIED                 => 1 +< 26,
    GIT_DIFF_PATIENCE                        => 1 +< 28,
    GIT_DIFF_MINIMAL                         => 1 +< 29,
    GIT_DIFF_SHOW_BINARY                     => 1 +< 30,
    GIT_DIFF_INDENT_HEURISTIC                => 1 +< 31,
);

enum Git::Diff::Flag (
    GIT_DIFF_FLAG_BINARY     => 1 +< 0,
    GIT_DIFF_FLAG_NOT_BINARY => 1 +< 1,
    GIT_DIFF_FLAG_VALID_ID   => 1 +< 2,
    GIT_DIFF_FLAG_EXISTS     => 1 +< 3,
);

enum Git::Delta::Type <
    GIT_DELTA_UNMODIFIED
    GIT_DELTA_ADDED
    GIT_DELTA_DELETED
    GIT_DELTA_MODIFIED
    GIT_DELTA_RENAMED
    GIT_DELTA_COPIED
    GIT_DELTA_IGNORED
    GIT_DELTA_UNTRACKED
    GIT_DELTA_TYPECHANGE
    GIT_DELTA_UNREADABLE
    GIT_DELTA_CONFLICTED
>;

class Git::Diff::File is repr('CStruct')
{
    HAS Git::Oid $.id;
    has Str $.path;
    has int64 $.size;
    has uint32 $.flags;
    has uint16 $.mode;
    has uint16 $.id-abbrev;
}

class Git::Diff::Delta is repr('CStruct')
{
    has int32 $.status;
    has uint32 $.flags;
    has uint16 $.similarity;
    has uint16 $.nfiles;
    HAS Git::Diff::File $.old-file;
    HAS Git::Diff::File $.new-file;
}

class Git::Diff is repr('CPointer') {...}

class Git::Diff::Options is repr('CStruct')
{
    has int32 $.version = 1;
    has uint32 $.flags = 0;
    has int32 $.ignore-submodules;
    HAS Git::Strarray $.pathspec;
    has Pointer $.notify-cb;
    has Pointer $.progress-cb;
    has int64 $.payload;
    has uint32 $.context-lines = 3;
    has uint32 $.interhunk-lines;
    has uint16 $.id-abbrev;
    has int64 $.max-size;
    has Str $.old-prefix;
    has Str $.new-prefix;

    submethod BUILD(
        Bool :$reverse,
        Bool :$include-ignored,
        Bool :$recurse-ignored-dirs,
        Bool :$include-untracked,
        Bool :$recurse-untracked-dirs,
        Bool :$include-unmodified,
        Bool :$include-typechange,
        Bool :$include-typechange-trees,
        Bool :$ignore-filemode,
        Bool :$ignore-submodules,
        Bool :$ignore-case,
        Bool :$include-casechange,
        Bool :$disable-pathspec-match,
        Bool :$skip-binary-check,
        Bool :$enable-fast-untracked-dirs,
        Bool :$update-index,
        Bool :$include-unreadable,
        Bool :$include-unreadable-as-untracked,
        Bool :$force-text,
        Bool :$force-binary,
        Bool :$ignore-whitespace,
        Bool :$ignore-whitespace-change,
        Bool :$ignore-whitespace-eol,
        Bool :$show-untracked-content,
        Bool :$show-unmodified,
        Bool :$patience,
        Bool :$minimal,
        Bool :$show-binary,
        Bool :$indent-heuristic,
        Git::Submodule::Ignore::Str :$submodules-ignore = 'UNSPECIFIED',
        uint32 :$!context-lines, uint32 :$!interhunk-lines,
        uint16 :$!id-abbrev, int64 :$!max-size,
        Str :$old-prefix, Str :$new-prefix)
    {
        $!flags = ($reverse ?? GIT_DIFF_REVERSE !! 0)
            +| ($include-ignored
                ?? GIT_DIFF_INCLUDE_IGNORED !! 0)
            +| ($recurse-ignored-dirs
                ?? GIT_DIFF_RECURSE_IGNORED_DIRS !! 0)
            +| ($include-untracked
                ?? GIT_DIFF_INCLUDE_UNTRACKED !! 0)
            +| ($recurse-untracked-dirs
                ?? GIT_DIFF_RECURSE_UNTRACKED_DIRS !! 0)
            +| ($include-unmodified
                ?? GIT_DIFF_INCLUDE_UNMODIFIED !! 0)
            +| ($include-typechange
                ?? GIT_DIFF_INCLUDE_TYPECHANGE !! 0)
            +| ($include-typechange-trees
                ?? GIT_DIFF_INCLUDE_TYPECHANGE_TREES !! 0)
            +| ($ignore-filemode
                ?? GIT_DIFF_IGNORE_FILEMODE !! 0)
            +| ($ignore-submodules
                ?? GIT_DIFF_IGNORE_SUBMODULES !! 0)
            +| ($ignore-case
                ?? GIT_DIFF_IGNORE_CASE !! 0)
            +| ($include-casechange
                ?? GIT_DIFF_INCLUDE_CASECHANGE !! 0)
            +| ($disable-pathspec-match
                ?? GIT_DIFF_DISABLE_PATHSPEC_MATCH !! 0)
            +| ($skip-binary-check
                ?? GIT_DIFF_SKIP_BINARY_CHECK !! 0)
            +| ($enable-fast-untracked-dirs
                ?? GIT_DIFF_ENABLE_FAST_UNTRACKED_DIRS !! 0)
            +| ($update-index
                ?? GIT_DIFF_UPDATE_INDEX !! 0)
            +| ($include-unreadable
                ?? GIT_DIFF_INCLUDE_UNREADABLE !! 0)
            +| ($include-unreadable-as-untracked
                ?? GIT_DIFF_INCLUDE_UNREADABLE_AS_UNTRACKED !! 0)
            +| ($force-text
                ?? GIT_DIFF_FORCE_TEXT !! 0)
            +| ($force-binary
                ?? GIT_DIFF_FORCE_BINARY !! 0)
            +| ($ignore-whitespace
                ?? GIT_DIFF_IGNORE_WHITESPACE !! 0)
            +| ($ignore-whitespace-change
                ?? GIT_DIFF_IGNORE_WHITESPACE_CHANGE !! 0)
            +| ($ignore-whitespace-eol
                ?? GIT_DIFF_IGNORE_WHITESPACE_EOL !! 0)
            +| ($show-untracked-content
                ?? GIT_DIFF_SHOW_UNTRACKED_CONTENT !! 0)
            +| ($show-unmodified
                ?? GIT_DIFF_SHOW_UNMODIFIED !! 0)
            +| ($patience
                ?? GIT_DIFF_PATIENCE !! 0)
            +| ($minimal
                ?? GIT_DIFF_MINIMAL !! 0)
            +| ($show-binary
                ?? GIT_DIFF_SHOW_BINARY !! 0)
            +| ($indent-heuristic
                ?? GIT_DIFF_INDENT_HEURISTIC !! 0);

        $!ignore-submodules = Git::Submodule::Ignore::{'GIT_SUBMODULE_IGNORE_'
                                                       ~ $submodules-ignore.uc};

        $!old-prefix := $old-prefix;
        $!new-prefix := $new-prefix;
    }
}

enum Git::Diff::Format::Email::Flags (
    GIT_DIFF_FORMAT_EMAIL_NONE                         => 0,
    GIT_DIFF_FORMAT_EMAIL_EXCLUDE_SUBJECT_PATCH_MARKER => 1 +< 0,
);

class Git::Diff::Format::Email::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    has int32 $.flags;
    has size_t $.patch-no;
    has size_t $.total-patches;
    has Git::Oid $.id;
    has Str $.summary;
    has Str $.body;
    has Git::Signature $.author;

    submethod BUILD(Bool :$exclude-subject-patch-marker,
                    size_t :$!patch-no = 1,
                    size_t :$!total-patches = 1,
                    Git::Oid :$id,
                    Str :$summary,
                    Str :$body,
                    Git::Signature :$author)
    {
        $!flags = GIT_DIFF_FORMAT_EMAIL_EXCLUDE_SUBJECT_PATCH_MARKER
            if $exclude-subject-patch-marker;
        $!id := $id;
        $!summary := $summary;
        $!body := $body;
        $!author := $author;
    }
}

class Git::Diff
{
    sub git_diff_free(Git::Diff)
        is native('git2') {}

    sub git_diff_format_email(Git::Buffer, Git::Diff,
                              Git::Diff::Format::Email::Options --> int32)
        is native('git2') {}

    method format-email()
    {
        my Git::Buffer $buf .= new;
        my Git::Diff::Format::Email::Options $opts .= new;
        check(git_diff_format_email($buf, self, $opts));
        $buf.str
    }

    method num-deltas(--> size_t)
        is native('git2') is symbol('git_diff_num_deltas') {}

    sub git_patch_from_diff(Pointer is rw, Git::Diff, size_t --> int32)
        is native('git2') {}

    method patch(size_t $idx)
    {
        my Pointer $ptr .= new;
        check(git_patch_from_diff($ptr, self, $idx));
        nativecast(Git::Patch, $ptr)
    }

    submethod DESTROY { git_diff_free(self) }
}
