import { describe, expect, it } from "vitest";
import { validateConfigObject } from "./config.js";

describe("sandbox workspaceRoot validation", () => {
  it("rejects empty workspaceRoot values", () => {
    const res = validateConfigObject({
      agents: {
        defaults: {
          sandbox: {
            workspaceRoot: "   ",
          },
        },
      },
    });
    expect(res.ok).toBe(false);
    if (!res.ok) {
      expect(res.issues[0]?.path).toBe("agents.defaults.sandbox.workspaceRoot");
      expect(res.issues[0]?.message).toContain("must not be empty");
    }
  });

  it("rejects filesystem root as workspaceRoot", () => {
    const res = validateConfigObject({
      agents: {
        defaults: {
          sandbox: {
            workspaceRoot: "/",
          },
        },
      },
    });
    expect(res.ok).toBe(false);
    if (!res.ok) {
      expect(res.issues[0]?.path).toBe("agents.defaults.sandbox.workspaceRoot");
      expect(res.issues[0]?.message).toContain("filesystem root");
    }
  });

  it("rejects top-level system directories for agent sandbox workspaceRoot", () => {
    const res = validateConfigObject({
      agents: {
        list: [
          {
            id: "main",
            sandbox: {
              workspaceRoot: "/etc",
            },
          },
        ],
      },
    });
    expect(res.ok).toBe(false);
    if (!res.ok) {
      expect(res.issues[0]?.path).toBe("agents.list.0.sandbox.workspaceRoot");
      expect(res.issues[0]?.message).toContain("top-level system directory");
    }
  });

  it("accepts a user-scoped sandbox workspaceRoot", () => {
    const res = validateConfigObject({
      agents: {
        defaults: {
          sandbox: {
            workspaceRoot: "~/.openclaw/sandboxes",
          },
        },
      },
    });
    expect(res.ok).toBe(true);
  });
});
