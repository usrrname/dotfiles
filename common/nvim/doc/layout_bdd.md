# LazyVim BDD Scenarios

## Startup Sequence

```gherkin
Feature: LazyVim Startup Sequence

  Scenario: Neovim starts with three-column layout
    Given Neovim is launched without arguments
    When the startup sequence completes
    Then Neo-tree should be open in the left window
    And OpenCode should be running in the right window
    And mini-starter should be displayed in the center

  Scenario: Mini-starter shows CrazyVim logo
    Given Neovim is launched without arguments
    When the startup sequence completes
    Then mini-starter header should display the ASCII "CRAZY" logo
    And the logo should be centered in the buffer

  Scenario: Unnamed buffers are cleaned up
    Given Neovim is launched without arguments
    When the startup sequence completes
    Then no unnamed buffers should remain
    And no [No Name] buffers should be visible

  Scenario: Startup skips when arguments are provided
    Given Neovim is launched with a file argument
    When Neovim starts
    Then the startup sequence should be skipped
    And the file should be opened normally

## Component Behavior

  Scenario: OpenCode toggle guard prevents duplicates
    Given OpenCode is already running
    When a user selects the opencode buffer tab
    Then only one OpenCode instance should exist
    And no additional windows should be created

  Scenario: Neo-tree persists during normal editing
    Given Neo-tree is open
    When the user opens a file
    Then Neo-tree should remain in the left sidebar

  Scenario: Buffer cleanup excludes special buffers
    Given the three-column layout is active
    When buffer cleanup runs
    Then neo-tree buffers should be preserved
    And OpenCode buffers should be preserved
    And mini-starter buffers should be preserved

## Keymap Functionality

  Scenario: <leader>aa opens OpenCode ask prompt
    Given OpenCode is running
    When the user presses <leader>aa
    Then an input prompt should appear
    And submitted text should be sent to OpenCode

  Scenario: <leader>ac executes OpenCode action
    Given text is selected in visual mode
    When the user presses <leader>ac
    Then OpenCode should process the selection
    And results should be displayed

  Scenario: Scroll keys navigate OpenCode
    Given OpenCode is visible
    When the user presses <S-Up>
    Then OpenCode should scroll up
    When the user presses <S-Down>
    Then OpenCode should scroll down

  Scenario: Ctrl+n leaves OpenCode terminal mode
    Given OpenCode is running in terminal mode
    When the user presses <Ctrl+n>
    Then terminal mode should exit
    And normal mode should be active in the OpenCode window

  Scenario: <leader>e toggles Neotree
    Given that Neotree is closed
    When the user presses <leader>e
    Then Neotree will open
    And the remaining windows will resize evenly

    Given that Neotree is open
    When the user presses <leader>e
    Then Neotree will close
    And the remaining buffers will still be open
    And split the windows evenly
```

## Validation Commands

```bash
nvim                          # Check startup layout
:Lazy sync                    # Verify plugin sync
:ls                           # Check buffer list (no unnamed)
```
