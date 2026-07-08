import { Button } from "@/components/ui/button";

// Sign out via a POST form so it works without client JS.
export function SignOutButton() {
  return (
    <form action="/auth/signout" method="post">
      <Button type="submit" variant="outline" size="sm">
        Sign out
      </Button>
    </form>
  );
}
