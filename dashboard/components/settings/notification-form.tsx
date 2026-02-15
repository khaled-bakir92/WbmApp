"use client";

import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  CardDescription,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Loader2 } from "lucide-react";
import { useUserConfig } from "@/hooks/use-user-config";

const notificationSchema = z.object({
  sender: z.string().email("Invalid email"),
  recipient: z.string().email("Invalid email"),
  password: z.string().min(1, "Required"),
  smtp_server: z.string().min(1, "Required"),
  smtp_port: z.number().min(1).max(65535),
});

type NotificationFormValues = z.infer<typeof notificationSchema>;

export function NotificationForm() {
  const { query, mutation } = useUserConfig();

  const form = useForm<NotificationFormValues>({
    resolver: zodResolver(notificationSchema),
    defaultValues: {
      sender: "",
      recipient: "",
      password: "",
      smtp_server: "",
      smtp_port: 587,
    },
  });

  useEffect(() => {
    if (query.data?.notification_email) {
      const ne = query.data.notification_email;
      form.reset({
        sender: ne.sender,
        recipient: ne.recipient,
        password: "", // Don't prefill masked password
        smtp_server: ne.smtp_server,
        smtp_port: ne.smtp_port,
      });
    }
  }, [query.data, form]);

  const onSubmit = (values: NotificationFormValues) => {
    mutation.mutate({ notification_email: values });
  };

  if (query.isLoading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>Notification Email</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-10 w-full" />
          ))}
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Notification Email</CardTitle>
        <CardDescription>
          SMTP settings for email notifications when new listings are found
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="sender">Sender</Label>
              <Input {...form.register("sender")} type="email" />
              {form.formState.errors.sender && (
                <p className="text-xs text-destructive">
                  {form.formState.errors.sender.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="recipient">Recipient</Label>
              <Input {...form.register("recipient")} type="email" />
              {form.formState.errors.recipient && (
                <p className="text-xs text-destructive">
                  {form.formState.errors.recipient.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                {...form.register("password")}
                type="password"
                placeholder="Re-enter to change"
              />
              {form.formState.errors.password && (
                <p className="text-xs text-destructive">
                  {form.formState.errors.password.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="smtp_server">SMTP Server</Label>
              <Input {...form.register("smtp_server")} />
              {form.formState.errors.smtp_server && (
                <p className="text-xs text-destructive">
                  {form.formState.errors.smtp_server.message}
                </p>
              )}
            </div>

            <div className="space-y-2">
              <Label htmlFor="smtp_port">SMTP Port</Label>
              <Input
                {...form.register("smtp_port", { valueAsNumber: true })}
                type="number"
                min={1}
                max={65535}
              />
              {form.formState.errors.smtp_port && (
                <p className="text-xs text-destructive">
                  {form.formState.errors.smtp_port.message}
                </p>
              )}
            </div>
          </div>

          <div className="flex gap-2 pt-2">
            <Button type="submit" disabled={mutation.isPending}>
              {mutation.isPending && (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              )}
              Save
            </Button>
            <Button
              type="button"
              variant="outline"
              onClick={() => {
                if (query.data?.notification_email) {
                  const ne = query.data.notification_email;
                  form.reset({
                    sender: ne.sender,
                    recipient: ne.recipient,
                    password: "",
                    smtp_server: ne.smtp_server,
                    smtp_port: ne.smtp_port,
                  });
                }
              }}
            >
              Reset
            </Button>
          </div>
        </form>
      </CardContent>
    </Card>
  );
}
