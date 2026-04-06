---
module: 6
lesson: 5
title: "Skills vs Commands Decision Framework"
prerequisites: ["lesson-6-4"]
test-out-compatible: true
version-pinned: "qwen-code>=0.1.0"
---

# Lesson 6.5: Skills vs Commands Decision Framework

## The Problem

You have a new requirement: your team needs a way to validate that all API endpoints follow the team's conventions. Should this be a command (e.g., `/validate-api`) that developers run when they want to check their code? Or should it be a skill that automatically applies the validation rules whenever someone works with API files? You understand both mechanisms individually, but you need a principled way to decide which approach to use -- and often, the best answer is both.

## Mental Model

Commands and skills are complementary, not competing. Commands are for workflows you explicitly trigger; skills are for knowledge the model should always have in a given context. The right choice depends on the activation pattern: if the user decides when to run it, use a command. If the context decides when to apply it, use a skill. In practice, the most powerful setups combine both -- skills provide the domain knowledge, commands trigger specific workflows using that knowledge.

## The Decision Framework

Use this framework to decide between a skill, a command, or both:

### Question 1: Who decides when it runs?

```
Does the user explicitly choose when to execute this?
    |
    +-- YES: The user triggers it --> COMMAND
    |   "I want to review my code now"
    |   "Generate the changelog"
    |   "Deploy to staging"
    |
    +-- NO: It should always apply --> SKILL
        "Always follow these naming conventions"
        "Always structure responses this way"
        "Always know about this framework"
```

### Question 2: Is it about knowledge or action?

```
Is this primarily about teaching the model something?
    |
    +-- YES: Knowledge transfer --> SKILL
    |   "Here is how our API framework works"
    |   "These are our team's naming conventions"
    |   "This is the deployment process"
    |
    +-- NO: It is about performing a task --> COMMAND
        "Review this PR for security issues"
        "Generate a changelog from commits"
        "Create a new endpoint from a template"
```

### Question 3: Does it produce output or guide behavior?

```
Does this produce a specific artifact or output?
    |
    +-- YES: Produces something --> COMMAND
    |   A commit message
    |   A changelog file
    |   A test report
    |
    +-- NO: Guides how the model thinks --> SKILL
        "Use async/await, not raw Promises"
        "Name files in kebab-case"
        "Always validate user input"
```

## Decision Matrix

| Scenario | Best Choice | Why |
|----------|------------|-----|
| Generate a commit message | Command | User triggers, produces output |
| Team naming conventions | Skill | Always applies, guides behavior |
| Security review workflow | Command | User initiates review |
| Terraform config format | Skill | Domain knowledge for .tf files |
| Daily standup note | Command | User triggers, produces file |
| API framework patterns | Skill | Context-aware knowledge |
| Changelog generation | Command | User triggers, produces output |
| Error handling patterns | Skill | Always applies to code |
| PR description generator | Command | User triggers, produces output |
| Database migration conventions | Skill | Domain knowledge for migration files |

## The Combined Pattern: Skill + Command

The most powerful pattern combines both: a skill provides domain knowledge, and a command triggers a specific workflow that leverages that knowledge.

### Example: API Framework

**Skill:** Provides the model with knowledge of the API framework conventions.

```
~/.qwen/skills/api-framework/
  SKILL.md           # Conventions the model always applies
  examples/          # Reference examples
  templates/         # Code templates
```

**Command:** Triggers a specific workflow using the skill's knowledge.

```
~/.qwen/commands/api/
  validate.md        # /api/validate - check code against conventions
  new-endpoint.md    # /api/new-endpoint - interactive endpoint creator
  review.md          # /api/review - review API code for issues
```

When you run `/api/validate`, the model already knows the conventions from the skill -- the command just triggers the specific action of checking code against those conventions.

### Example: Terraform

**Skill:** Terraform knowledge -- resource types, state management, best practices.

```
~/.qwen/skills/terraform/
  SKILL.md
  examples/
  modules/
```

**Command:** Specific Terraform workflows.

```
~/.qwen/commands/terraform/
  plan.md       # /terraform/plan - run plan with formatting
  validate.md   # /terraform/validate - check for issues
  cost.md       # /terraform/cost - estimate infrastructure cost
```

## Try It: Build a Combined Skill + Command

### Step 1: Create the skill

```bash
mkdir -p ~/.qwen/skills/testing-conventions
cat > ~/.qwen/skills/testing-conventions/SKILL.md << 'EOF'
---
name: testing-conventions
description: "Testing conventions and patterns for this project"
triggers:
  - "*.test.js"
  - "*.test.ts"
  - "*.spec.js"
  - "*.spec.ts"
  - file: "jest.config.js"
  - file: "vitest.config.js"
---

# Skill: testing-conventions

## Test Organization
- Tests live next to source files: `user-service.js` -> `user-service.test.js`
- Test directories mirror source directory structure
- Shared test helpers go in `test/helpers/`
- Test fixtures go in `test/fixtures/`

## Test Structure (AAA Pattern)
All tests follow Arrange-Act-Assert:

```javascript
describe('UserService', () => {
  it('should create a user with valid data', async () => {
    // Arrange
    const service = new UserService(db);
    const userData = { name: 'Alice', email: 'alice@example.com' };

    // Act
    const user = await service.create(userData);

    // Assert
    expect(user.id).toBeDefined();
    expect(user.name).toBe('Alice');
    expect(user.email).toBe('alice@example.com');
  });
});
```

## Naming Conventions
- describe blocks: describe the unit being tested
- it blocks: describe the expected behavior in present tense
- "should <behavior> when <condition>"
- Never use "correctly" or "properly" in test names

## Mocking
- Mock external dependencies at the module boundary
- Use `jest.mock()` or `vi.mock()` at the top of the test file
- Never mock the unit under test
- Use test doubles from `test/helpers/mocks.js`

## Coverage Requirements
- Minimum 80% line coverage
- All public methods must have tests
- Error paths must be tested (not just happy path)
EOF
```

### Step 2: Create commands that use the skill

```bash
mkdir -p ~/.qwen/commands/testing
```

```bash
cat > ~/.qwen/commands/testing/review-tests.md << 'EOF'
---
name: review-tests
description: "Review test files for convention compliance"
---

# Command: review-tests

Review the test files in the current project against the team's testing
conventions.

## Process

1. Find all test files: `find . -name "*.test.js" -o -name "*.test.ts" -o -name "*.spec.js" -o -name "*.spec.ts"`

2. For each test file, check:
   - Tests follow the AAA (Arrange-Act-Assert) pattern
   - describe/it blocks follow naming conventions
   - Mocks are placed at the top of the file
   - Error paths are tested (not just happy path)
   - Test names use present tense: "should <behavior> when <condition>"

3. Report findings in a table:

| File | Issue | Severity | Line |
|------|-------|----------|------|

Severity levels:
- CRITICAL: Missing tests for public methods
- MAJOR: Not following AAA pattern
- MINOR: Naming convention violation

4. Provide a summary:
   - Total files reviewed
   - Total issues found by severity
   - Overall compliance percentage

5. Suggest specific fixes for the top 3 most impactful improvements.
EOF
```

```bash
cat > ~/.qwen/commands/testing/generate-test.md << 'EOF'
---
name: generate-test
description: "Generate a test file for a source file"
---

# Command: generate-test

Arguments provided: {{args}}

Generate a test file for the specified source file following the team's
testing conventions.

## Process

1. If {{args}} is provided, it is the path to the source file to test.
   If {{args}} is empty, ask the user for the file path.

2. Read the source file and understand:
   - What it exports (functions, classes, constants)
   - What dependencies it imports
   - What the public API looks like

3. Generate a test file with:
   - One test per public export (minimum)
   - Happy path tests for each function/method
   - Error path tests for each function that can throw
   - Edge case tests (empty input, boundary values, etc.)
   - Tests following AAA pattern
   - Following naming conventions

4. The test file should be named: `<source-file-name>.test.<ext>`
   and placed in the same directory as the source file.

5. Show the generated test file and ask if the user wants to save it.
EOF
```

### Step 3: Test the combined setup

Create a project with test files:

```bash
mkdir -p /tmp/test-project
cd /tmp/test-project
cat > user-service.js << 'JSEOF'
class UserService {
  constructor(db) {
    this.db = db;
  }

  async create(userData) {
    if (!userData.name || !userData.email) {
      throw new Error('Name and email are required');
    }
    return this.db.insert('users', userData);
  }

  async findById(id) {
    return this.db.findOne('users', { id });
  }
}

module.exports = { UserService };
JSEOF

cat > user-service.test.js << 'JSEOF'
const { UserService } = require('./user-service');

describe('UserService', () => {
  it('works', async () => {
    const service = new UserService({ insert: () => ({ id: 1 }) });
    const user = await service.create({ name: 'Alice', email: 'a@b.com' });
    expect(user.id).toBe(1);
  });
});
JSEOF

touch jest.config.js
```

Now start Qwen Code:

```bash
cd /tmp/test-project
qwen
```

Try:

```
# The testing-conventions skill should be active automatically
Is my test file following the conventions?

# Use the review command
/review-tests

# Use the generate command
/generate-test user-service.js
```

The skill provides the knowledge (what the conventions are), and the commands trigger specific actions (reviewing and generating) using that knowledge.

## When to Choose Each Approach

### Use a Command When:

- You want to run something on demand
- The workflow has multiple steps the user might want to skip
- The output is an artifact (file, report, message)
- The user needs to provide parameters or make choices
- It is a periodic or occasional task (not every coding session needs it)

### Use a Skill When:

- The knowledge should always be active in a certain context
- You want the model to automatically follow conventions
- The knowledge helps with any task in that domain
- It is about reducing friction, not adding a step
- New team members need to learn the domain quickly

### Use Both When:

- You have domain knowledge that should always apply AND specific workflows to trigger
- The skill teaches conventions and the command enforces them
- The skill provides reference material and the command generates code from it
- You want the best of both worlds: automatic knowledge + explicit workflows

## Anti-Patterns to Avoid

### Anti-Pattern 1: Skill That Should Be a Command

```markdown
# In a SKILL.md - WRONG
When the user wants to generate a changelog, run `git log` and format it...
```

This should be a command. The model should not wait passively for the user to "want" a changelog -- the user should explicitly trigger it with `/changelog`.

**Fix:** Move to a command file:
```bash
~/.qwen/commands/changelog.md
```

### Anti-Pattern 2: Command That Should Be a Skill

```markdown
# In a command file - WRONG
# Command: code-style
# Run this command every time you write code to follow these conventions...
```

This should be a skill. Code style conventions should always apply, not just when the user remembers to run a command.

**Fix:** Move to a skill:
```bash
~/.qwen/skills/code-style/SKILL.md
```

### Anti-Pattern 3: Command That Duplicates a Skill

```bash
# Command: api-conventions
# This command teaches you about the API framework...
```

If the API conventions should always apply, they belong in a skill, not a command you need to remember to run. A command can reference the skill's knowledge but should not duplicate it.

## Check Your Work

Evaluate your commands and skills against the framework:

```bash
echo "=== Decision Framework Audit ==="
echo ""
echo "Commands (should be triggered, produce output):"
find ~/.qwen/commands/ -name "*.md" -type f 2>/dev/null | while read f; do
  name=$(grep "^name:" "$f" | head -1 | cut -d' ' -f2-)
  echo "  $name"
done

echo ""
echo "Skills (should be automatic, guide behavior):"
find ~/.qwen/skills/ -name "SKILL.md" -type f 2>/dev/null | while read f; do
  name=$(grep "^name:" "$f" | head -1 | cut -d' ' -f2-)
  echo "  $name"
done

echo ""
echo "Check: Are any skills describing one-off tasks? Move to commands."
echo "Check: Are any skills about conventions that should always apply? Keep as skills."
echo "=== Done ==="
```

## Debug It

### Scenario: Command duplicates skill knowledge

Your command file repeats conventions that are already in a skill.

**Fix:** The command should reference the skill, not duplicate it:

```markdown
# Instead of repeating conventions:
Follow the testing conventions (see testing-conventions skill):
- Tests follow AAA pattern
- Mocks at top of file
- Test public methods

Now, for THIS specific workflow:
1. Find test files
2. Check coverage
3. Report results
```

### Scenario: Skill and command conflict

The skill says "always use async/await" but a command suggests using raw Promises.

**Fix:** The command should be consistent with the skill. If the skill establishes a rule, all commands should follow it. The model should catch the inconsistency, but do not rely on that -- keep your files consistent yourself.

### Scenario: Neither skill nor command feels right

You have a requirement that seems to fall between both.

**Fix:** This often means you need BOTH. The skill provides the background knowledge, the command triggers the specific task. If you are still unsure, start with a command (explicit is better than implicit) and refactor to a skill later if the knowledge proves broadly applicable.

## Module 6 Complete

You have completed the Skills & Auto-Discovery module. Here is what you can now do:

- Understand the difference between skills (automatic knowledge) and commands (explicit workflows)
- Write complete skills with SKILL.md, triggers, and supporting files
- Design precise triggers that activate skills at the right time
- Build skills with examples, templates, and reference files
- Decide when to use a skill, a command, or both using the decision framework

Your skills and commands together form a complete system: skills give Qwen Code domain knowledge automatically, while commands give you explicit control over specific workflows.

---

**Module 6 complete.** You now know how to build skills with auto-discovery, write effective triggers, organize supporting files, and make principled decisions between skills and commands.

**Coming up in Module 7:** Advanced Workflows -- combine commands, skills, and other Qwen Code features to build sophisticated multi-step pipelines for review, deployment, and code generation.
