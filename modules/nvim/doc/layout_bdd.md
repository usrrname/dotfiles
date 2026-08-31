# LazyVim BDD Scenarios

## Startup Sequence

```gherkin
Feature: LazyVim Startup Sequence

  Scenario: Neovim starts with neo-tree on the left
    Given Neovim is launched without arguments
    When the startup sequence completes
    Then Neo-tree should be open in a left split (winfixwidth)
    And mini-starter should be displayed in the center
    And OpenCode should have been pre-warmed in the background

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

  Scenario: OpenCode toggles as a float
    Given OpenCode is running in the background
    When the user presses <leader>oo
    Then the OpenCode float should appear on the right edge
    And focus should enter terminal mode
    When the user presses <leader>oo again
    Then the float should hide
    And the editor layout should be unchanged

  Scenario: OpenCode float is immune to layout changes
    Given OpenCode float is visible
    When the user opens neo-tree or a terminal split
    Then the float should not move or resize
    And the TUI should not glitch

  Scenario: Neo-tree persists during normal editing
    Given Neo-tree is open
    When the user opens a file
    Then Neo-tree should remain in the left split

  Scenario: Buffer cleanup excludes special buffers
    Given Neovim is running with the normal startup layout
    When buffer cleanup runs
    Then neo-tree buffers should be preserved
    And OpenCode buffers should be preserved
    And mini-starter buffers should be preserved

## Keymap Functionality

  Scenario: <leader>oa opens OpenCode ask prompt
    Given OpenCode is running
    When the user presses <leader>oa
    Then an ask prompt should appear
    And submitted text should be sent to OpenCode

  Scenario: <leader>oc executes OpenCode action
    Given text is selected in visual mode
    When the user presses <leader>oc
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
    Then Neotree will open as a left split with winfixwidth
    And the editor window will fill the remaining space

    Given that Neotree is open
    When the user presses <leader>e
    Then Neotree will close
    And the editor window will fill the full width
```

## Validation Commands

```bash
nvim                          # Check startup layout
:Lazy sync                    # Verify plugin sync
:ls                           # Check buffer list (no unnamed)
```
